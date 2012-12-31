require 'wakari/multilang'

module Wakari

  module ActiveRecordExtension
    extend ActiveSupport::Concern
  
    module ClassMethods
      class_eval do
        include Wakari::Multilang
      end
    end
  end
  
end
