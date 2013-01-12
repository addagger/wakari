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
          order = bg.delete(:order)||bg.delete("order")
          bg.each do |key, value|
            send(key, value, order, &block)
          end
        end
      
        def alive_order
          alive_translations.map(&:locale)
        end
        
        def background
          {:order => alive_order}
        end
        
        # Transitions commands
        
        def add(locale, order, &block)
          engage(order << locale) do |t|
            if t.locale == locale.to_s
              t.instance_variable_set(:@marked_for_destruction, false) if t.marked_for_destruction?
              yield(t, :add) if block_given?
            end
          end
        end
        
        def remove(locale, order, &block)
          engage(order) do |t|
            if t.locale == locale.to_s
              t.persisted? ? t.mark_for_destruction : translations.target.delete(t) && translations.target.compact!
              yield(t, :remove) if block_given?
            end
          end
          sort(order - [locale])
        end
        
        def move_up(locale, order, &block)
          engage(move_up_locale(locale, order)) do |t|
            yield(t, :move_up) if t.locale == locale.to_s && block_given?
          end
        end
        
        def move_down(locale, order, &block)
          engage(move_down_locale(locale, order)) do |t|
            yield(t, :move_down) if t.locale == locale.to_s && block_given?
          end
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
      
        def remove_from_order(locale_or_object)
          background.tap do |bg|
            bg[:remove] = recognize(locale_or_object)
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
          order = possible_langs.validate_codes(*order, :raise => true)
          (order|used_langs.codes).each.with_index do |locale, index|
            t = detect_translation(locale)
            translations.target.insert(index, translations.target.delete(t))
            if block_given?
              yield t, index+1
            end
          end
          translations.target.compact!
        end

        def iterate_order(order = [], &block) # only with used locales
          order = used_langs.validate_codes(*order, :raise => true)
          (order|used_langs.codes).each.with_index do |locale, index|
            t = translation(locale)
            translations.target.insert(index, translations.target.delete(t))
            if block_given?
              yield t, index+1
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

        def moveable_up?(locale_or_object)
          alive_translations.first != recognize(locale_or_object)
        end
        
        def moveable_down?(locale_or_object)
          alive_translations.last != recognize(locale_or_object)
        end
        
        def removeable?(locale_or_object)
          !the_only_alive?(locale_or_object)
        end
        
        def the_only_alive?(locale_or_object)
          alive_translations.size == 1 && alive_translations.first == recognize(locale_or_object)
        end
        
        def the_only?(locale_or_object)
          translations.size == 1 && translations.first == recognize(locale_or_object)
        end
      end
    
    end
  end
end