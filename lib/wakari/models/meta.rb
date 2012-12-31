require 'wakari/models/meta/model'
require 'wakari/models/meta/reference'

module Wakari
  module Meta
    class String < ActiveRecord::Base
      self.table_name = "meta_strings"
      attr_accessible :value
      validates_presence_of :value
    end
    
    class Text < ActiveRecord::Base
      self.table_name = "meta_texts"
      attr_accessible :value
      validates_presence_of :value
    end

    # class StringReference < ActiveRecord::Base
    #   self.table_name = "references"
    #   attr_accessible :meta_id, :reference_id
    #   include Meta::Reference  
    # end
    # 
    # class TextReference < ActiveRecord::Base
    #   self.table_name = "references"
    #   attr_accessible :meta_id, :reference_id
    #   include Meta::Reference  
    # end

  end
end