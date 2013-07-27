module MyCalls
  class Client
    module Concerns

      module Search
        extend ActiveSupport::Concern

        include Url

        module ClassMethods

          # Searched and returns objects whose first name, last name or e-mail
          # match the given +keyword+.
          #
          # @param  [String] keyword
          # @return [Array] objects matching the given keyword, may be empty
          #
          def search(keyword)
            instantiate_collection client.get("#{self.url}/search", :params => {:q => keyword})
          rescue Error::NotFound
            []
          end

        end

      end

    end
  end
end
