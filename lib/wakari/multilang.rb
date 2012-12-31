require 'wakari/bundle'

module Wakari  
  module Multilang
    
    def multilang(*args, &block)
      bundle = Bundle.new(self, *args)
      bundle.prepare!
      yield bundle if block_given?
    end
    
  end
  
end