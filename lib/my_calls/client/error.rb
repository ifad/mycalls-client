module MyCalls
  class Client

    class Error < StandardError
      class Empty < self   ; end
      class Timeout < self ; end
      class NotFound < self; end
    end

  end
end
