module Wakari
  module TranslateFields
    module Assets
      class Content
        attr_reader :t_builder
        delegate :template, :builder, :transitions, :proxy, :translation, :render, :tag_attributes, :content_tag, :to => :t_builder
      
        def initialize(t_builder)
          @t_builder = t_builder
        end
      
        def tag_id
          "wakari-content"
        end
      
        def visible?
          true
        end
      
        def content
        end

        def unvisible_content
        end
  
        def default_tag
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end

        def default_html_options
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end

        def html(*args)
          options = args.extract_options!
          tag = args.first||default_tag
          html_options = tag_attributes(:id => tag_id, :style => visible? ? nil : "display: none;").merge(default_html_options).merge(options).stringify_values
          content_tag tag, visible? ? content : unvisible_content, html_options
        end
  
        def js_remove
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end
  
      end
    
      class SelectLocaleContent < Content
        def visible?
          transitions[:select] == true
        end
      
        def content
          render("#{proxy.t_model_name.collection}/select_locale", :t_builder => t_builder)
        end
      
        def tag_id
          proxy.dom_id(:select_locale)
        end
  
        def js_appear
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end
  
        def js_disappear
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end
  
      end
  
      class Fields < Content
        def visible?
          proxy.translations.any?
        end
        
        def content
          t_builder.t_translations.map {|t| t.fields.html}.join.html_safe
        end
      
        def tag_id
          proxy.dom_id
        end
      end
    
      class TranslationFields < Content
        delegate :position, :to => :translation

        def visible?
          translation && !translation.marked_for_destruction?
        end

        def content
          if visible?
            render(translation.fields_path, :f => t_builder.builder, :t_builder => t_builder)
          else
            t_builder.builder.hidden_field :_destroy
          end
        end

        def unvisible_content
          content
        end

        def tag_id
          translation.dom_id(:fields)
        end

        def next
          t_builder.next.try(:fields)
        end
        
        def prev
          t_builder.prev.try(:fields)
        end

        def js_moving_up
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end

        def js_moving_down
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end

        def js_refresh_position
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end
  
        def js_adding
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end
        
        def js_removing
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end
        
        def js_removing_persisted
          t_builder.get_config_value_for_class(self.class, __method__, template, self)
        end
  
      end
    end
  end
end