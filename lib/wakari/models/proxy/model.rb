require 'wakari/models/support/errors'

module Wakari
  module Proxy
    module Model
      extend ActiveSupport::Concern
    
      included do
      end

      module ClassMethods
        def acts_as_proxy(translation_class, association_name, options)
          lang_methods = translation_class._locales.collect do |lang|
                           method = lang.to_method
                           class_eval <<-EOV
                             def #{method}
                               translation?(\"#{lang.code}\")
                             end
                             def #{method}=(params={})
                               detect_translation(\"#{lang.code}\").tap do |t|
                                 t.attributes = params.delete_if {|k| k.to_s == \"locale\"}
                               end
                             end
                           EOV
                            method
                         end
          attr_accessible *lang_methods
          delegate *translation_class._meta_attributes, :to => :current_translation, :allow_nil => true
          delegate *translation_class._meta_attributes.collect {|attribute| "#{attribute}="}, :to => :detect_current_translation, :allow_nil => true
          
          if self < Wakari::Proxy::Base
            define_method :translations do |*args|
              content.send(association_name, *args)
            end
          end
          
        end
      end

      def translations_attributes
        Hash[translations.map do |t|
               if (lang = t.lang) && (attributes = t.meta_attributes).present?
                 [lang.to_method, attributes]
               end
             end.compact]
      end

      def possible_langs
        translations.klass._locales
      end

      def used_langs
        translations.map {|t| t.lang}
      end

      def available_langs
        possible_langs - used_langs
      end

      def default_translation
        translations.min_by {|t| t.position}
      end

      def translation(locale)
        find_translation(:locale => locale)
      end
      
      def translation?(locale)
        begin
          translation(locale)
        rescue TranslationNotFound
          nil
        end
      end

      def detect_translation(locale)
        find_or_build_translation(:locale => locale)
      end

      def current_translation
         translation?(current_locale)
      end
      
      def detect_current_translation
        detect_translation(current_locale)
      end
            
      def to_s(locale = nil)
        (locale ? translation?(locale) : current_translation||translations.first).try(:to_s)
      end

      private

      def build_translation(params = {})
        translations.build(params)
      end

      def find_or_build_translation(params = {})
        begin
          find_translation(params)
        rescue TranslationNotFound
          build_translation(params)
        end
      end

      def find_translation(params = {})
        translations.find {|t| t.match?(params)} || raise(TranslationNotFound, params)
      end

    end
    
  end
end