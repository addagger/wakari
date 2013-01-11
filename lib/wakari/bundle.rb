require 'wakari/models/content'
require 'wakari/models/proxy'
require 'wakari/models/translation'
require 'wakari/models/meta'

module Wakari
  
  class Bundle

    attr_reader :content_class, :proxy_class, :translation_class, :meta_class, :options

    def initialize(content_class, *args)
      @content_class = content_class
      @name = args.first
      @options = args.extract_options!
    end

    def name
      @name.to_s.underscore if @name
    end

    def translation_name
      name||"translation"
    end

    def full_translation_name
      [content_class.model_name.param_key, translation_name].join("_")
    end

    def translation_class
      @translation_class ||= case options[:class_name]
      when nil then
        content_class.const_set(translation_name.classify, Class.new(Wakari::Translation::Base))
      when String, Symbol then
        options[:class_name].to_s.constantize
      end
    end
    
    def meta_class
      @meta_class ||= case options[:meta]
      when :text then
        translation_class.const_set("Meta", Class.new(Wakari::Meta::Text))
      when :string then
        translation_class.const_set("Meta", Class.new(Wakari::Meta::String))
      when String, Symbol then
        options[:meta].to_s.constantize
      else
        raise "#{content_class.name}: Meta model expected for multilang definition#{" :" + name if name }."
      end
    end
    
    def proxy_class
      if proxy_need?
        @proxy_class ||= content_class.const_set("#{name.classify}Proxy", Class.new(Wakari::Proxy::Base))
      end
    end
    
    def prepare!
      meta_class.send(:include, Wakari::Meta::Model)
      meta_class.send(:acts_as_meta_class, *meta_class_args)
      
      translation_class.send(:include, Wakari::Translation::Model)
      translation_class.send(:acts_as_translation_class, *translation_class_args)
      
      content_class.send(:include, Wakari::Content::Model)
      content_class.send(:acts_as_content_class, *content_class_args)
            
      if proxy_class
        proxy_class.send(:include, Wakari::Proxy::Model)
        proxy_class.send(:acts_as_proxy, *proxy_class_args)
        content_class.class_eval <<-EOV
          attr_accessible :#{name}
          
          def #{name}
            #{proxy_class}.new(self)
          end
          def #{name}=(*args)
            #{proxy_class}.new(self).assign(*args)
          end
        EOV
       else
        content_class.send(:include, Wakari::Proxy::Model) unless content_class < Wakari::Proxy::Model
        content_class.send(:acts_as_proxy, *proxy_class_args)
      end
    end
    
    private
    
    def proxy_need?
      name.present?
    end
    
    def association_name
      translation_name.pluralize.to_sym
    end
    
    def full_association_name
      full_translation_name.pluralize.to_sym
    end
    
    def translation_class_options
      options
    end
    
    def translation_class_args
      [content_class, association_name, meta_class, full_association_name, proxy_class, translation_class_options]
    end
    
    def meta_class_options
      options
    end
    
    def meta_class_args
      [translation_class, full_association_name, meta_class_options]
    end
    
    def proxy_class_options
      options
    end
    
    def proxy_class_args
      [translation_class, association_name, proxy_class_options]
    end
    
    def content_class_options
      options
    end
    
    def content_class_args
      [translation_class, association_name, content_class_options]
    end
    
  end

  
end