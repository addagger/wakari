module Wakari
  module Support
    module Transition
      class Actor
        attr_reader :added, :removed
        delegate :translations, :translation, :translation?, :detect_translation, :alive_translations,
                 :used_langs, :possible_langs, :to => "@base"
        def initialize(base)
          @base = base
        end
        
        def sort(order = [], &block) # change attribute
          iterate_order(order) do |t, position|
            t.position = position if t.position != position
            yield t if block_given?
          end
          @base
        end
      
        def sort!(order = [], &block) # update attribute immediately
          iterate_order(order) do |t, position|
            t.update_column(:position, position) if t.position != position
            yield t if block_given?
          end
          @base
        end
      
        def engage(order = [], &block) # change attribute
          engage_order(order) do |t, position|
            t.position = position if t.position != position
            yield t if block_given?
          end
          @base
        end
        
        def wrap(bg = {}, &block)
          bg = bg.kabuki if bg.is_a?(String)
          engage(bg.delete(:order)||bg.delete("order"))
          bg.each do |key, value|
            if key.to_s.in? %w{add remove select move_up move_down}
              if respond_to?(key)
                send(key, value, &block)
              elsif block_given?
                yield(key, value)
              end
            end
          end
        end
      
        def alive_order
          alive_translations.map(&:locale)
        end

        def order
          translations.map {|t| t.marked_for_destruction? ? "#{t.locale}*" : t.locale}
        end
        
        def background
          {:order => order}
        end
        
        # Transitions commands
        
        def add(locale, &block)
          t = detect_translation(locale)
          t.unmark_for_destruction if t.marked_for_destruction?
          yield(__method__, t) if block_given?
          sort(alive_order)
        end
        
        def remove(locale, &block)
          t = translation?(locale)
          t.persisted? ? t.mark_for_destruction : translations.target.delete(t) && translations.target.compact!
          yield(__method__, t) if block_given?
          sort(alive_order)
        end

        def move_up(locale, &block)
          t = translation?(locale)
          yield(__method__, t) if block_given?
          sort(move_up_locale(t.locale))
        end
        
        def move_down(locale, &block)
          t = translation?(locale)
          yield(__method__, t) if block_given?
          sort(move_down_locale(t.locale))
        end

        # Recognize to locale
        
        def recognize(locale_or_object)
          case locale_or_object
          when translations.klass then locale_or_object.locale
          when String, Symbol then possible_langs.validate_codes(locale_or_object).first
          else raise(TypeError, "Undefined type")
          end
        end

        # Transitions orders
      
        def add_to_order(locale_or_object)
          background.tap do |bg|
            bg[:add] = recognize(locale_or_object)
          end
        end
        
        def remove_from_order(locale_or_object)
          background.tap do |bg|
            bg[:remove] = recognize(locale_or_object)
          end
        end

        def move_up_in_order(locale_or_object)
          background.tap do |bg|
            bg[:move_up] = recognize(locale_or_object)
          end
        end

        def move_down_in_order(locale_or_object)
          background.tap do |bg|
            bg[:move_down] = recognize(locale_or_object)
          end
        end
      
        private

        def move_up_locale(locale, with_order = alive_order)
          with_order.tap do |order|
            index = order.index(locale) - 1
            unless index < 0
              order.insert(index, order.delete(locale))
            end
          end
        end

        def move_down_locale(locale, with_order = alive_order)
          with_order.tap do |order|
            index = order.index(locale) + 1
            unless index >= order.size
              order.insert(index, order.delete(locale))
            end
          end
        end

        def engage_order(order = [], &block) # only with used locales
          index = 0
          order.each do |locale|
            t = detect_translation(locale[/(\w|-)+/])
            if locale[/\*\z/]
              t.mark_for_destruction
            else
              t.unmark_for_destruction if t.marked_for_destruction?
              translations.target.insert(index, translations.target.delete(t))
              index += 1
              if block_given?
                yield t, index
              end
            end
          end
          translations.target.compact!
        end

        def iterate_order(order = [], &block) # only with used locales
          index = 0
          order.each do |locale|
            t = detect_translation(locale[/(\w|-)+/])
            if locale[/\*\z/]
              t.mark_for_destruction
            else
              t.unmark_for_destruction if t.marked_for_destruction?
              translations.target.insert(index, translations.target.delete(t))
              index += 1
              if block_given?
                yield t, index
              end
            end
          end
          translations.target.compact!
        end
        
      end

      module ProxyMethods
        def t_transitions
          Actor.new(self)
        end

        def t_transitions=(bg = {})
          transitions.wrap(bg)
        end
        
        # Recognize to translation object

        def recognize(locale_or_object)
          case locale_or_object
          when translations.klass then locale_or_object
          when String, Symbol then translation?(locale_or_object)
          when nil then nil
          else raise(TypeError, "Undefined type")
          end
        end

        # Transitions conditions

        def alive_index(locale_or_object)
          alive_translations.index(recognize(locale_or_object))
        end
        
        def index(locale_or_object)
          translations.index(recognize(locale_or_object))
        end

        def movable_up?(locale_or_object)
          alive_translations.first != recognize(locale_or_object)
        end
        
        def movable_down?(locale_or_object)
          alive_translations.last != recognize(locale_or_object)
        end
        
        def removable?(locale_or_object)
          !the_only_alive?(locale_or_object)
        end
        
        def the_only_alive?(locale_or_object)
          alive_translations.size == 1 && alive_translations.first == recognize(locale_or_object)
        end
        
        def the_only?(locale_or_object)
          translations.size == 1 && translations.first == recognize(locale_or_object)
        end

        def next_to(locale_or_object)
          if index = alive_index(locale_or_object)
            next_index = index + 1
            translations.at(next_index) if next_index <= alive_translations.size - 1
          end
        end

        def prev_to(locale_or_object)
          if index = alive_index(locale_or_object)
            prev_index = index - 1
            translations.at(prev_index) if prev_index >= 0
          end
        end

      end
    
    end
  end
end