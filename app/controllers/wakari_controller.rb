class WakariController < ApplicationController
  
  def self.controller_path
    unless anonymous?
      @controller_path ||= begin
        model_name = name.sub(/Controller$/, '').singularize
        model_name.constantize.model_name.collection.tap do |t|
          t.instance_eval do
            def include?(arg)  # Rails hack! actionpack/lib/action_view/renderer/partial_renderer.rb
              arg == "/" ? false : super
            end
          end
        end
      end
    end
  end

end