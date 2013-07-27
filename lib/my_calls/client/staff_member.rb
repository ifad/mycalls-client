require "my_calls/client/base"
require 'debugger'

module MyCalls
  class Client

    class StaffMember < Base

      include MyCalls::Client::Concerns::Find
      include MyCalls::Client::Concerns::Search
      include MyCalls::Client::Concerns::Magic

      self.url = 'staff_members'

    end

  end
end
