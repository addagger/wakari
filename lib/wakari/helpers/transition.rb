module Wakari
  class TransitionUrl
    def initialize(proxy, locale_or_object, action, options = {})
      @proxy = proxy
      @translation, @lang = *case locale_or_object
      when Wakari::Translation::Model then
        [locale_or_object, locale_or_object.lang]
      when String, Symbol then
        [@proxy.translation?(locale_or_object), Gaigo::LANGS.get(locale_or_object)]
      when Gaigo::Langs::Lang then
        [@proxy.translation?(locale_or_object.code), locale_or_object]
      else
        [nil, nil]
      end
      @action = action
      @options = options||{}
      @path = case @options[:path]
      when Hash then @options[:path]
      when String then Rails.application.routes.recognize_path(@options[:path])
      when nil then {}
      end
    end
    
    def transition
      case @action
      when :select then
        @proxy.t_transitions.background.merge(:select => true, :object_name => @options[:builder].object_name)
      when :add then
        @proxy.t_transitions.add_to_order(@lang.code).merge(:object_name => @options[:builder].object_name)
      when :remove then
        @proxy.t_transitions.remove_from_order(@translation)
      when :move_up then
        @proxy.t_transitions.move_up_in_order(@translation)
      when :move_down then
        @proxy.t_transitions.move_down_in_order(@translation)
      end
    end
    
    def url_hash
      @path.merge(@proxy.translations_key => transition.kabuki!)
    end
    
  end
  
  module TransitionHelpers
  end
end