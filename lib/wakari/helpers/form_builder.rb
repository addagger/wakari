module Wakari
  class FormBuilder
    attr_reader :template, :builder, :proxy
    
    
    def initialize(template, builder, proxy)
      @template = template
      @proxy = proxy
      @builder = builder
    end
    
    class Translation
      attr_reader :form_builder, :translation, :lang, :builder
      
      delegate :template, :proxy, :url_hash, :to => :form_builder
      
      def initialize(form_builder, locale_or_object)
        @form_builder = form_builder
        
        @translation, @lang = *case locale_or_object
        when Wakari::Translation::Model then
          [locale_or_object, locale_or_object.lang]
        when String, Symbol then
          [proxy.translation?(locale_or_object), Gaigo::LANGS.get(locale_or_object)]
        when Gaigo::Langs::Lang then
          [proxy.translation?(locale_or_object.code), locale_or_object]
        else
          [nil, nil]
        end
        
        if proxy.dedicated_proxy?
          @form_builder.builder.fields_for proxy.name do |proxy_name_builder|
             @proxy_builder = proxy_name_builder
          end
        end
      
        (@proxy_builder||@form_builder.builder).fields_for @translation.lang.to_method, @translation do |translation_builder|
          @builder = translation_builder
        end
      end
      
      def fields
        @translation.marked_for_destruction? ? render_destroy_hidden_field : render_fields
      end
      
      def render_destroy_hidden_field
        @builder.hidden_field :_destroy
      end
      
      def render_fields
        template.render(@translation.fields_path, :f => @builder, :proxy => proxy, :translation => translation)
      end
      
      def transition_url(action, path = {})
        url_hash(transition(action), path)
      end
      
      private
      
      def transition(action)
        case action
        when :remove then
          proxy.t_transitions.remove_from_order(@translation)
        when :move_up then
          proxy.t_transitions.move_up_in_order(@translation)
        when :move_down then
          proxy.t_transitions.move_down_in_order(@translation)
        end
      end
      
    end
    
    def translation(locale_or_object)
      Translation.new(self, locale_or_object)
    end
    
    def select_locale_url_hash(path = {})
      url_hash(@proxy.t_transitions.background.merge(:select => true), path)
    end
    
    def add_locale_url_hash(locale, path = {})
      url_hash(@proxy.t_transitions.add_to_order(locale), path)
    end
    
    
    def url_hash(hash, path = {})
      recognize_path(path).merge(@proxy.translations_key => hash.merge(:object_name => builder.object_name).kabuki!)
    end
    
    private
    
    def recognize_path(path = {})
      case path
      when Hash then path
      when String then Rails.application.routes.recognize_path(path)
      when nil then {}
      end
    end
    
  end
  
  module FormBuilderHelpers
    def t_form_builder(builder_or_object_name, proxy)
      case builder_or_object_name
      when String, Symbol then
        fields_for builder_or_object_name do |custom_builder|
          builder = custom_builder
        end
      when ActionView::Helpers::FormBuilder then
        builder = builder_or_object_name
      end
      FormBuilder.new(self, builder, proxy)
    end
  end
end