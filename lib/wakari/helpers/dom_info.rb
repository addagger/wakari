module Wakari
  class DomInfo
    attr_reader :object
    
    def initialize(object)
      @object = object
    end
    
    def inspect
      to_s
    end
    
    def content_dom_class(klass)
      klass.model_name.param_key
    end
    
    def translation_dom_class(klass)
      klass.model_name.element
    end
    
    def elements
      case object
      when Wakari::Content::Model then
        [content_dom_class(object.class), object.id]
      when Wakari::Translation::Model then
        [content_dom_class(object.association(:content).klass), object.content_id, translation_dom_class(object.class), object.locale]
      when Wakari::Proxy::Base then
        [DomInfo.new(@object.content).id, translation_dom_class(object.translations.klass)]
      end
    end
    
    def to_s
      id
    end
    
    def id(prefix = nil)
      [prefix, *elements].compact.join("_")
    end
  end

end