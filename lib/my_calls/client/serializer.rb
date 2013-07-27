require "oj"

module MyCalls
  class Client

    module Serializer
      extend self

      def load(json)
        Oj.load(json, :mode => :object)
      end

      def dump(object)
        Oj.dump(object, :mode => :object)
      end
    end

  end
end
