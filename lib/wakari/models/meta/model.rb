module Wakari
  module Meta
    
    module Model
      extend ActiveSupport::Concern
    
      included do
      end
    
      module ClassMethods
        def acts_as_meta_class(translation_class, full_association_name, options)
          has_many full_association_name, :class_name => "::Object::#{translation_class.name}", :inverse_of => :meta, :order => :created_at, :foreign_key => :meta_id
        end
      end
    
      def to_s
        value
      end
      
    end
  end
end