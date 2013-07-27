require 'rails/railtie'

module MyCalls
  class Railtie < ::Rails::Railtie

    initializer 'my_calls.setup_instrumentation' do
      require 'my_calls/instrumentation'

      MyCalls::Instrumentation::LogSubscriber.attach_to :my_calls

      ActiveSupport.on_load(:action_controller) do
        include MyCalls::Instrumentation::ControllerRuntime
      end
    end

  end
end
