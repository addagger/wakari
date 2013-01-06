require 'wakari/models/support/naming'

module Wakari
  module Translation
    
    module Model
      extend ActiveSupport::Concern
      include Wakari::Support::Naming
      
      included do
        class_attribute :_meta_attributes unless defined?(_meta_attributes)
        
        validates_presence_of :locale
        validates_uniqueness_of :locale, :scope => [:type, :content_id]
        before_save :commit_meta
        after_destroy :clear_meta     
        after_initialize do
          template_meta
        end
        acts_as_list :scope => [:type, :content_id]
        default_scope { includes(:meta) }
      end

      module ClassMethods
  
        def dom_class
          model_name.element
        end

        def acts_as_translation_class(content_class, association_name, meta_class, full_association_name, options)
          has_locale! *Array.wrap(options[:locales])#, :accessible => false

          belongs_to :content, :class_name => "::Object::#{content_class.name}", :inverse_of => association_name, :counter_cache => :"#{association_name}_count"
          belongs_to :meta, :class_name => "::Object::#{meta_class.name}", :inverse_of => full_association_name, :counter_cache => :wakari_used

          self._meta_attributes =
          if meta_class < Wakari::Meta::Text || meta_class < Wakari::Meta::String
            [:value]
          else
            Array.wrap(options[:attributes]).map {|a| a.to_sym}
          end

          attr_accessible *_meta_attributes, :content_id, :meta_id, :_destroy, :position
          delegate_attributes *_meta_attributes, :to_s, :errors => :fit, :to => "(@_template_meta||meta)"
          delegate_attributes *_meta_attributes.map {|attribute| "#{attribute}="}, :errors => false, :to => :template_meta
          
          (class << self; self; end).instance_eval do
            define_method :i18n_inherited_namespaced_scope do |resource| #:nodoc:
              :"#{content_class.i18n_namespaced_scope(resource)}.#{model_name.element}"
            end

            define_method :i18n_inherited_default_scope do |resource| #:nodoc:
              :"#{content_class.i18n_default_scope(resource)}.#{model_name.element}"
            end
          end

          define_method :stack do
            content.send(association_name)
          end
          
         end

        def try_human_attribute_name(attribute, options = {})
          super(attribute, options) do |defaults|
            defaults << :"#{i18n_inherited_namespaced_scope(:attributes)}.#{attribute}" ## added
            defaults << :"#{i18n_inherited_default_scope(:attributes)}.#{attribute}" ## added
          end
        end
        
        def human_attribute_name(attribute, options = {})
          try_human_attribute_name(attribute, options)
        end
        
      end

      def dom_id(prefix = nil)
        [prefix, content.dom_id, self.class.dom_class, locale].compact.join("_")
      end

      def _destroy=(value)
        case value
        when 1, '1', true, 'true' then
          mark_for_destruction
        end
      end

      def siblings
        stack - [self]
      end

      def meta_counter
        counter = association(:meta).options[:counter_cache]
        counter = self.class.model_name.plural + "_count" if counter == true
        meta.send(counter) if counter
      end

      def only_once_used_meta?
        meta_counter && meta_counter <= 1
      end

      def changed?
        meta_changed? || super
      end

      def meta_changed?
        eval(_meta_attributes.map {|a| "template_meta.send(:#{a}) != meta.send(:#{a})"}.join(" || ")) ## content changed?
      end

      def match?(params = {})
        m = params.map {|key, value| send(key) == (value.is_a?(Symbol) ? value.to_s : value)}
        (m.include?(false) || m.blank?) ? false : true
      end

      def meta_attributes
        Hash[_meta_attributes.map {|attr| value = send(attr); [attr.to_s, value] if value}.compact]
      end

      def lang
        Gaigo::LANGS.get(locale)
      end

      def to_param
        locale
      end

      def meta=(object)
        begin
          super
        ensure
          @_template_meta = object.dup
        end
      end

      private
    
      def template_meta
        @_template_meta ||= meta ? meta.dup : build_meta.dup
      end
    
      def clear_meta
        if only_once_used_meta?
          destroy_meta
        end
      end
    
      def commit_meta
        if meta_changed? ## writer attributes touched
          attributes = extract_attributes(template_meta)
          if meta.persisted?
            if only_once_used_meta?
              if exists_meta?(attributes)
                destroy_meta
                attach_or_create_meta(attributes)
              else
                update_meta(attributes)
              end
            else
              attach_or_create_meta(attributes)
            end
          else
            attach_or_create_meta(attributes)
          end
        end
      end

      def extract_attributes(object)
        object.attributes.delete_if {|a| !a.to_sym.in?(_meta_attributes)}
      end
      
      def destroy_meta
        begin
          meta.destroy
          puts "Translation '#{locale}': PERSISTED META DESTROYED!"
        rescue ActiveRecord::StaleObjectError
          meta.reload
          commit_meta
        end
      end
      
      def update_meta(attributes = {})
        begin
          meta.update_attributes(attributes)
          puts "Translation '#{locale}': PERSISTED META UPDATED!"
        rescue ActiveRecord::StaleObjectError
          meta.reload
          commit_meta
        end
      end

      def find_existed_meta(attributes = {})
        association(:meta).klass.where(attributes).limit(1).first
      end

      def create_new_meta(attributes = {})
        create_meta(attributes).tap do |record|
          record.send(:increment_lock) # Rails BUG! Counter caching process increments lock version in the DB table,
                                       # but not in the associated object. So saving raises ActiveRecord::StaleObjectError.
        end
      end

      def exists_meta?(attributes = {})
        association(:meta).klass.exists?(attributes)
      end

      def attach_or_create_meta(attributes = {})
        if existed = find_existed_meta(attributes)
          self.meta = existed
          puts "Translation '#{locale}': EXISTED META USED!"
        else
          self.meta = create_new_meta(attributes)
          puts "Translation '#{locale}': NEW META CREATED!"
        end
      end
    
    end
  end
  
end