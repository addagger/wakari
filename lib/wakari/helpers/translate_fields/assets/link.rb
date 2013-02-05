module Wakari
  module TranslateFields
    module Assets
      class Link
        attr_reader :t_builder
        delegate :template, :builder, :proxy, :translation, :link_to, :tag_attributes, :url_hash, :to => :t_builder
        delegate :url_for, :capture, :to => :template

        def initialize(t_builder)
          @t_builder = t_builder
        end
      
        def tag_id
          proxy.dom_id
        end
      
        def visible?
          true
        end

        def visible_href
          respond_to?(:visible_url_hash) ? url_for(visible_url_hash) : template.request.fullpath
        end

        def unvisible_href
          respond_to?(:unvisible_url_hash) ? url_for(unvisible_url_hash) : template.request.fullpath
        end

        def href
          visible? ? visible_href : unvisible_href
        end

        def visible_style
          nil
        end
      
        def unvisible_style
          "display: none;"
        end
      
        def style
          visible? ? visible_style : unvisible_style
        end
      
        def default_html_options
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end
      
        def html(name = nil, html_options = nil, &block)
          html_options = name if block_given?
          html_options = tag_attributes(:id => tag_id, :style => style).merge(default_html_options).merge(html_options).stringify_values
          if block_given?
             link_to(href, html_options, &block)
          else
            link_to(name, href, html_options, &block)
          end
        end
  
        def js_refresh
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end

        def js_hide
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end

        def js_show
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end
  
      end
    
      class LinkToSelectLocale < Link  
        def visible?
          proxy.available_langs.any? 
        end
      
        def visible_url_hash
          url_hash(proxy.t_transitions.background.merge(:select => true))
        end
      
        def tag_id
          proxy.dom_id + "_select_link"
        end
      end
    
      class LinkToAddLocale < Link
        def initialize(lang, t_builder)
          @lang = lang
          super(t_builder)
        end
      
        def visible?
          proxy.available_langs.any? 
        end
      
        def visible_url_hash
          url_hash(proxy.t_transitions.add_to_order(@lang.code))
        end
      
        def tag_id
          proxy.dom_id + "_add_link"
        end
      end
    
      class LinkToRemoveFields < Link
        def visible?
          proxy.removable?(translation)
        end
      
        def visible_url_hash
          url_hash(proxy.t_transitions.remove_from_order(translation))
        end
      
        def tag_id
          translation.dom_id + "_remove_link"
        end
      end
    
      class LinkToMoveUpFields < Link
        def visible?
          proxy.movable_up?(translation)
        end
      
        def visible_url_hash
          url_hash(proxy.t_transitions.move_up_in_order(translation))
        end
      
        def tag_id
          translation.dom_id + "_move_up_link"
        end
      end

      class LinkToMoveDownFields < Link
        def visible?
          proxy.movable_down?(translation)
        end
      
        def visible_url_hash
          url_hash(proxy.t_transitions.move_down_in_order(translation))
        end
      
        def tag_id
          translation.dom_id + "_move_down_link"
        end
      end
    end
  end
end