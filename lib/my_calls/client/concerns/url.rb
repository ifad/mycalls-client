module MyCalls
  class Client
    module Concerns

      module Url
        extend ActiveSupport::Concern

        module ClassMethods

          # Gets the API endpoint URL
          #
          # @return [String] the url
          #
          def url
            @url
          end

          # Sets the API endpoint URL
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
