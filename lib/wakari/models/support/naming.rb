module Wakari
  module Support
    module Naming
      extend ActiveSupport::Concern
    
      class Name < ActiveModel::Name
        attr_reader :parent_class

        def initialize(parent_class, klass, namespace = nil, name = nil)
          super(klass, namespace, name)
          @parent_class = parent_class
          @clear_name   = (Rails.version <= "3.2.8" ? (name||klass.name) : @name).sub(/^#{parent_class.name}\W*/,'')
          @singular     = _singularize(@clear_name)
          @plural       = ActiveSupport::Inflector.pluralize(@singular)
          @element       = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(@clear_name))
          @collection   = @parent_class.model_name.collection + "/" + ActiveSupport::Inflector.tableize(@clear_name)
          @param_key    = (namespace ? _singularize(@unnamespaced) : @singular)
          @i18n_key     = (@parent_class.model_name.i18n_key.to_s + "/" + @clear_name.underscore).to_sym
          @route_key          = (namespace ? ActiveSupport::Inflector.pluralize(@param_key) : @plural.dup)
          @singular_route_key = ActiveSupport::Inflector.singularize(@route_key)
          @route_key << "_index" if @plural == @singular
        end
        
        def human(options = {})
          try_human(options)
        end
        
      end
    
      module ClassMethods
        def parent_class
          self.name.split("::")[0..-2].join("::").constantize
        end
  
        def _to_partial_path #:nodoc:
          @_to_partial_path ||= begin
            "#{model_name.collection}/#{model_name.element}".freeze
          end
        end

        def _to_fields_path #:nodoc:
          "#{model_name.collection}/fields"
        end  

        def model_name
          @_model_name ||= begin
            namespace = self.parents.detect do |n|
              n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
            end
            Name.new(parent_class, self, namespace)
          end
        end
      end
    
    end
  end
end