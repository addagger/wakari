require "wakari/helpers/dom_info"
require "wakari/helpers/translate_fields"

module Wakari
  
  module ActionViewExtension
    extend ActiveSupport::Concern
  
    included do
    end
    
    include DomHelpers
    include TranslateFieldsHelpers
  end

end
