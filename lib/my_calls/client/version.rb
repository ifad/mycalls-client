module MyCalls
  class Client

    module Version
      MAJOR = 0
      MINOR = 1
      PATCH = 0
      BUILD = 'beta1'

      STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join(".")
    end

    VERSION = Version::STRING

  end
end
