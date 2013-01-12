require "wakari/helpers/dom_info"

module Wakari
  
  module ActionViewExtension
    extend ActiveSupport::Concern
  
    included do
    end
		
		def wdom_id(object, prefix = nil)
			DomInfo.new(object).id(prefix)
		end

  end

end
