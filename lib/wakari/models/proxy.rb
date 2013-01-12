require 'wakari/models/proxy/model'

module Wakari
  module Proxy
    class Base
      #include ActiveModel::AttributeMethods
      include ActiveModel::MassAssignmentSecurity
      attr_reader :content
      delegate :current_locale, :current_lang, :to => :content
      delegate :==, :nil?, :present?, :to => :current_translation
      
      extend ActiveModel::Naming
      
      def initialize(content)
        @content = content
      end
      
      # def translations
      #   _translations_proc.call(content)
      # end
      
      def assign(params={})
        params.each do |key, value|
          if Gaigo::LANGS.get_by_method(key)
            send("#{key}=", value)
          else
            raise "Invalid language accessor passed: :#{key}"
          end
        end
      end
      
      def inspect
        translations.inspect
      end
      
      def method_missing(*args, &block)
        current_translation.send(*args, &block)
      end

      def dom_id(prefix = nil)
        DomInfo.new(self).id(prefix)
      end
      
    end
  end
end