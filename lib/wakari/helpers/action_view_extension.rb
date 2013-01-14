require "wakari/helpers/dom_info"
require "wakari/helpers/form_builder"

module Wakari
  
  module ActionViewExtension
    extend ActiveSupport::Concern
  
    included do
    end
    
    include DomHelpers
    include FormBuilderHelpers

  end

end
