require 'wakari/helpers/translate_fields/config_class'
require 'wakari/helpers/translate_fields/translation'
require 'wakari/helpers/translate_fields/assets/content'
require 'wakari/helpers/translate_fields/assets/link'

module Wakari
  module TranslateFields
    class Base      
      attr_reader :template, :builder, :proxy, :proxy_builder, :path_hash, :transitions
      delegate :params, :render, :link_to, :tag_attributes, :content_tag, :capture, :to => :template
    
      def initialize(template, builder, proxy, config_class = nil)
        @config_class = config_class||Configuration
        raise(TypeError, "Invalid config class: #{@config_class.name}. Wakari::TranslateFields::Configuration expected.") unless @config_class <= Configuration
        @template = template
        @proxy = proxy
        @builder = builder
        if proxy.dedicated_proxy?
          @builder.fields_for(proxy.name) do |proxy_builder|
            @proxy_builder = proxy_builder
          end
        end
        @path_hash = recognize_path(get_config_value(:path, @template))
        @transitions = {}
        if bg
          proxy.t_transitions.wrap(bg) { |action, value| @transitions[action] = value }
        end
      end

      def base_builder
        @proxy_builder||@builder
      end

      def bg
        params[proxy.translations_key]
      end
    
      def select_locale(*args)
        Assets::SelectLocaleContent.new(self)
      end

      def get_config_value(*args)
        @config_class.send(:try, *args)
      end
      
      def get_config_value_for_class(klass, key, *args)
        result = nil
        klass.ancestors.each do |c|
          method_name = [c.name.demodulize.underscore, key].compact.join("_")
          begin
            result = get_config_value(method_name, *args)
          rescue
          end
          break if result || c == Object
        end
        result
      end

      def t_translations
        proxy.translations.map {|t| translation(t)}
      end

      def translation(locale_or_object)
        object = case locale_or_object
        when Wakari::Translation::Model then
          locale_or_object
        when String, Symbol then
          proxy.translation?(locale_or_object)
        when Gaigo::Langs::Lang then
          proxy.translation?(locale_or_object.code)
        else
          nil
        end
        Translation.new(self, object)
      end
    
      def url_hash(hash = {})
        path_hash.merge(proxy.translations_key => hash.merge(:object_name => builder.object_name).kabuki!)
      end

      def fields
        Assets::Fields.new(self)
      end

      def link_to_select_locale
        Assets::LinkToSelectLocale.new(self)
      end
    
      def link_to_add_fields(lang_or_locale)
        lang = case lang_or_locale
        when Gaigo::Langs::Lang then lang_or_locale
        else proxy.available_langs.get(lang_or_locale)
        end
        Assets::LinkToAddLocale.new(lang, self)
      end

      def js_correction
        t_translations.map(&:js_correction).join.html_safe
      end
      
      def js_response
        buffer = []
        if transitions[:select]
          buffer << select_locale.js_appear
        end
        if t = transitions[:add]
          fields = translation(t).fields
          buffer << fields.js_remove
          buffer << fields.js_adding
          buffer << select_locale.js_disappear
          buffer << link_to_select_locale.js_refresh
          buffer << js_correction
        end
        if t = transitions[:remove]
          fields = translation(t).fields
          buffer << (t.persisted? ? fields.js_removing_persisted : fields.js_removing)
          buffer << link_to_select_locale.js_refresh
          buffer << js_correction
        end
        buffer.join.html_safe
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
  end
  
  module TranslateFieldsHelpers
    module FormBuilderExtension
      def translate_fields(proxy = nil, config_class = nil, &block)
        @template.translate_fields(self, proxy, config_class, &block)
      end
    end
    ::ActionView::Helpers::FormBuilder.send(:include, FormBuilderExtension)
    
    def translate_fields(builder_or_object_name, proxy, config_class = nil, &block)
      builder =
      case builder_or_object_name
      when String, Symbol then
        send(:instantiate_builder, builder_or_object_name, proxy.translatable, {})
      when ActionView::Helpers::FormBuilder then
        builder_or_object_name
      end
      t_builder = Wakari::TranslateFields::Base.new(self, builder, proxy, config_class)
      yield t_builder if block_given?
      if request.xhr?
        t_builder.js_response
      end
    end

    def ajax_translate_fields(proxy, config_class = nil, &block)
      if bg = params[proxy.translations_key]
        translate_fields(bg.kabuki[:object_name], proxy, config_class, &block)
      end
    end

  end

end