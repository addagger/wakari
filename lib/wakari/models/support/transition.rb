module Wakari
  module Support
    module Transition
      module ProxyMethods
        def sort_translations(order = [], &block) # change attribute
          order_translations(order) do |t, position|
            t.position = position if t.position != position
          end
          self
        end
      
        def sort_translations!(order = [], &block) # update attribute immediately
          order_translations(order) do |t, position|
            t.update_column(:position, position) if t.position != position
          end
          self
        end
      
        def init_order(order = [], &block)
          missing_translations = translations.target.dup
          engage_translations(order) do |t, position|
            missing_translations -= [t] 
            t.instance_variable_set(:@marked_for_destruction, false) if t.marked_for_destruction?
            t.position = position if t.position != position
          end
          missing_translations.each do |t|
            if t.persisted?
              t.mark_for_destruction
            else
              translations.delete(t)
            end
          end
          self
        end
      
        def actual_translations
          translations.select {|t| !t.marked_for_destruction?}
        end
      
        def actual_order
          actual_translations.map(&:locale)
        end
        
        def add_translation_order(locale)
          actual_order + [locale.to_s]
        end
      
        private

        def engage_translations(order = [], &block)
          order = possible_langs.validate_codes(*order, :raise => true)
          (order|used_langs.codes).each.with_index do |locale, index|
            t = detect_translation(locale)
            translations.target.insert(index, translations.target.delete(t)) if translations.include?(t)
            if block_given? && locale.in?(order)
              yield t, index+1
            end
          end
        end

        def order_translations(order = [], &block)
          order = used_langs.validate_codes(*order, :raise => true)
          (order|used_langs.codes).each.with_index do |locale, index|
            t = translation(locale)
            translations.target.insert(index, translations.target.delete(t))
            if block_given?
              yield t, index+1
            end
          end
        end
      end
    
      module TranslationMethods
        def move_up_order
          order = proxy.actual_order
          index = order.index(locale) + 1
          unless index >= order.size
            order.insert(index, order.delete(locale))
          end
          order
        end

        def move_down_order
          order = proxy.actual_order
          index = order.index(locale) - 1
          unless index < 0
            order.insert(index, order.delete(locale))
          end
          order
        end
      
        def remove_order
          order = proxy.actual_order
          order.delete(locale)
          order
        end
      end
    end
  end
end