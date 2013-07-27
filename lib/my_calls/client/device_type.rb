require "my_calls/client/base"

module MyCalls
  class Client

    class DeviceType < Base

      include MyCalls::Client::Concerns::Find
      include MyCalls::Client::Concerns::Magic

      self.url = 'device_types'

    end

  end
end
