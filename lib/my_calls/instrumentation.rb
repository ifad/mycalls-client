require 'active_support/log_subscriber'

module MyCalls
  module Instrumentation

    # LogSubscriber to log MyCalls request URLs and timings
    #
    # h/t https://gist.github.com/566725
    #
    class LogSubscriber < ActiveSupport::LogSubscriber
      def request(event)
        self.class.runtime += event.duration

        url = event.payload[:url]
        if event.payload[:params] && event.payload[:params].respond_to?(:to_param)
          url += '?' << event.payload[:params].to_param
        end

        info '  MyCalls: %s %s (%.1fms) - cache %s' % [
          event.payload[:method].upcase,
          url,
          event.duration,
          event.payload[:cached] ? 'HIT' : 'MISS'
        ]
      end

      class << self
        def runtime=(value)
          Thread.current[:my_calls_runtime] = value
        end

        def runtime
          Thread.current[:my_calls_runtime] ||= 0
        end

        def reset_runtime
          rt, self.runtime = runtime, 0
          rt
        end
      end
    end

    # ActionController Instrumentation to log time spent in MyCalls
    # requests at the bottom of log messages.
    #
    module ControllerRuntime
      extend ActiveSupport::Concern

      attr_internal :my_calls_runtime

      def append_info_to_payload(payload)
        super
        payload[:my_calls_runtime] = (my_calls_runtime || 0) + MyCalls::Instrumentation::LogSubscriber.runtime
      end
      protected :append_info_to_payload

      def cleanup_view_runtime
        my_calls_rt_before_render = MyCalls::Instrumentation::LogSubscriber.reset_runtime
        runtime = super
        my_calls_rt_after_render = MyCalls::Instrumentation::LogSubscriber.reset_runtime
        self.my_calls_runtime = my_calls_rt_before_render + my_calls_rt_after_render
        runtime - my_calls_rt_after_render
      end
      protected :cleanup_view_runtime

      module ClassMethods
        def log_process_action(payload)
          messages, my_calls_runtime = super, payload[:my_calls_runtime]
          messages << ("MyCalls: %.1fms" % my_calls_runtime.to_f) if my_calls_runtime
          messages
        end
      end

    end
  end
end
