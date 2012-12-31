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
      
      def write(params={})
        detect_current_translation.tap do |t|
          t.attributes = params.delete_if {|k| k.to_s == "locale"}
        end
      end
      
      def inspect
        translations.inspect
      end
      
      def method_missing(*args, &block)
        current_translation.send(*args, &block)
      end

      def dom_id(prefix = nil)
        [prefix, content.dom_id, translations.klass.dom_class].compact.join("_")
      end
      
    end
  end
end