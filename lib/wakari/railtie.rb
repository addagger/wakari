require 'rails'

module Wakari
  class Railtie < ::Rails::Railtie
    config.before_initialize do
      ActiveSupport.on_load :active_record do
        require 'wakari/models/active_record_extension'
        include Wakari::ActiveRecordExtension
      end
      ActiveSupport.on_load :action_controller do
        require 'wakari/controllers/action_controller_extension'
        include Wakari::ActionControllerExtension
      end
      ActiveSupport.on_load :action_view do
        require 'wakari/helpers/action_view_extension'
        include Wakari::ActionViewExtension
      end
    end
  end
end