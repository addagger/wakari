module Wakari
  module TranslateFields
    module ConfigModel
      extend ::ActiveSupport::Concern

      module ClassMethods

        def path(template)
          {}
        end

        def select_locale_content_default_tag(template, select_locale)
          :span
        end

        def select_locale_content_default_html_options(template, select_locale)
          {:class => __method__}
        end

        def fields_default_tag(template, fields)
          :div
        end

        def fields_default_html_options(template, fields)
          {:class => __method__}
        end

        def translation_fields_default_tag(template, t_fields)
          :div
        end

        def translation_fields_default_html_options(template, t_fields)
          {:class => __method__}
        end

        def link_to_select_locale_default_html_options(template, link)
          {:class => __method__}
        end

        def link_to_add_locale_default_html_options(template, link)
          {:class => __method__}
        end

        def link_to_remove_fields_default_html_options(template, link)
          {:class => __method__}
        end

        def link_to_move_up_fields_default_html_options(template, link)
          {:class => __method__}
        end

        def link_to_move_down_fields_default_html_options(template, link)
          {:class => __method__}
        end

        def link_js_refresh(template, link)
          %Q{$('##{link.tag_id}').attr('href', '#{link.href}');}
        end

        def link_js_hide(template, link)
          %Q{$('##{link.tag_id}').hide();}
        end

        def link_js_show(template, link)
          %Q{$('##{link.tag_id}').show();}
        end

        def content_js_remove(template, content)
          %Q{$('##{tag_id}').remove();}
        end

        def select_locale_content_js_appear(template, select_locale)
          "$('##{select_locale.tag_id}').replaceWith('#{template.escape_javascript(select_locale.html)}').hide().fadeIn();"
        end

        def select_locale_content_js_disappear(template, select_locale)
          "$('##{select_locale.tag_id}').empty();"
        end

        def translation_fields_js_refresh_position(template, fields)
          %Q{$('##{fields.tag_id}').find('input[name$="[position]"]').attr("value", "#{fields.position}");}
        end

        def translation_fields_js_adding(template, fields)
          %Q{$('#{template.escape_javascript(fields.html)}').hide().appendTo('##{fields.proxy.dom_id}').fadeIn();}
        end

        def translation_fields_js_removing(template, fields)
          %Q{$('##{fields.tag_id}').fadeOut(300, function(){ $(this).remove(); });}
        end

        def translation_fields_js_removing_persisted(template, fields)
          %Q{$('##{fields.tag_id}').replaceWith('#{template.escape_javascript(fields.html)}');}
        end

      end

    end
    class Configuration
      include ConfigModel
    end
  end
end