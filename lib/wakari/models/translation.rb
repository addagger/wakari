require 'wakari/models/translation/model'

module Wakari
  module Translation
    
    class Base < ActiveRecord::Base
      self.table_name = "translations"
    end
        
  end
  
end