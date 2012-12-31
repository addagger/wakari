module Wakari
  module Content
    module Model
      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods
    
        def acts_as_content_class(translation_class, association_name, options)
          has_many association_name, :class_name => translation_class.name, :inverse_of => :content, :order => :position, :autosave => true, :foreign_key => :content_id
          default_scope { includes(association_name) }
        end
    
        def i18n_namespaced_scope(resource) #:nodoc:
          :"#{self.i18n_scope}.#{resource}.#{self.model_name.i18n_key.to_s.gsub(/\//,".")}"
        end

        def i18n_default_scope(resource) #:nodoc:
          :"#{self.i18n_scope}.#{resource}.#{self.model_name.i18n_key.to_s}"
        end
    
        def dom_class
          model_name.param_key
        end
    
      end

      def dom_id(prefix = nil)
        [prefix, self.class.dom_class, to_key].compact.join("_")
      end

      def current_locale
        I18n.locale.to_s
      end

      def current_lang
        Gaigo::LANGS.get(current_locale)
      end


    end
  end
end