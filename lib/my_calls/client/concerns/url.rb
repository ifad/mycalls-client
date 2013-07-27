module MyCalls
  class Client
    module Concerns

      module Url
        extend ActiveSupport::Concern

        module ClassMethods

          # Returns the url which the client instance wil call on each requres
          #
          # @return [String] the url
          #
          def url
            @url
          end

          # Sets the url which the client instance wil call on each requres
          #
          # @param  [String] u the url
          # @return [String] the url
          #
          def url=(u)
            @url = u
          end

        end

      end

    end
  end
end
