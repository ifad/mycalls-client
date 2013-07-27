require "my_calls/client/base"

module MyCalls
  class Client

    class Device < Base

      include MyCalls::Client::Concerns::Find
      include MyCalls::Client::Concerns::Search
      include MyCalls::Client::Concerns::Magic

      self.url = 'devices'

    end

  end
end
