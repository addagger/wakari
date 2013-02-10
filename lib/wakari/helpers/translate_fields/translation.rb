require 'wakari/helpers/translate_fields/assets/content'
require 'wakari/helpers/translate_fields/assets/link'

module Wakari
  module TranslateFields
    class Translation
      attr_reader :translation, :lang, :builder

      delegate :get_config_value, :get_config_value_for_class, :template, :proxy, :url_hash, :base_builder, :to => :@base
      delegate :render, :link_to, :tag_attributes, :content_tag, :to => :template

      def initialize(base, translation)
        @base = base
        @translation = translation
        @lang = @translation.try(:lang)
        base_builder.fields_for(@translation.lang.to_method, @translation) do |translation_builder|
          @builder = translation_builder
        end
      end

      def field_name(name)
        builder.object_name + "[#{name}]"
      end

      def fields
        eval "@#{__method__} ||= Assets::TranslationFields.new(self)"
      end

      def link_to_remove_fields
        eval "@#{__method__} ||= Assets::LinkToRemoveFields.new(self)"
      end

      def link_to_move_up_fields
        eval "@#{__method__} ||= Assets::LinkToMoveUpFields.new(self)"
      end

      def link_to_move_down_fields
        eval "@#{__method__} ||= Assets::LinkToMoveDownFields.new(self)"
      end

      def next
        if @base.transitions[:move_down] == translation
          @base.translation(proxy.prev_to(translation))
        else
          @base.translation(proxy.next_to(translation))
        end
      end
      
      def prev
        if @base.transitions[:move_up] == translation
          @base.translation(proxy.next_to(translation))
        else
          @base.translation(proxy.prev_to(translation))
        end
      end
      
      def removable?
        proxy.removable?(translation)
      end
      
      def movable_up?
        proxy.movable_up?(translation)
      end
      
      def movable_down?
        proxy.movable_down?(translation)
      end

      def js_correction
        buffer = []
        buffer << fields.js_refresh_position
        buffer << (removable? ? link_to_remove_fields.js_show : link_to_remove_fields.js_hide)
        buffer << link_to_remove_fields.js_refresh

        buffer << (movable_up? ? link_to_move_up_fields.js_show : link_to_move_up_fields.js_hide)
        buffer << link_to_move_up_fields.js_refresh

        buffer << (movable_down? ? link_to_move_down_fields.js_show : link_to_move_down_fields.js_hide)
        buffer << link_to_move_down_fields.js_refresh
        buffer.join.html_safe
      end

    end
  end
end