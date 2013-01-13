require "wakari/helpers/dom_info"
require "wakari/helpers/transition"

module Wakari
  
  module ActionViewExtension
    extend ActiveSupport::Concern
  
    included do
    end
    
    include DomHelpers
    include TransitionHelpers

  end

end
