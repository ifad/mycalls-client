module MyCalls
  class Client

    module Concerns
      autoload :Url,           "my_calls/client/concerns/url"
      autoload :Find,          "my_calls/client/concerns/find"
      autoload :Search,        "my_calls/client/concerns/search"
      autoload :Magic,         "my_calls/client/concerns/magic"
    end

  end
end
