require "wakari/version"

module Wakari
  def self.load!
    require 'wakari/engine'
    require 'wakari/railtie'
  end

end

Wakari.load!