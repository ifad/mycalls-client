module MyCalls
  class Client
    module Concerns

      module Magic
        extend ActiveSupport::Concern

        include Url

        module ClassMethods

          # Executes the method as url and returns objects
          # match the given +params+ as first argument.
          #
          # @param  [Hash] params
          # @return [Array] objects for the url matching the method
          #
          def method_missing(meth, *args, &block)
            instantiate_collection(client.get("#{self.url}/#{meth}", :params => args.shift)).tap do |response|
              block.call(response) if block
            end
          rescue Error::NotFound
            []
          end

        end


        # Executes the method as sub url of the current call and returns objects
        # match the given +params+ as first argument.
        #
        # @param  [Hash] params
        # @return [Array] objects for the url matching the method
        #
        def method_missing(meth, *args, &block)
          self.class.instantiate_collection(client.get("#{self.class.url}/#{id}/#{meth}", :params => args.shift)).tap do |response|
            block.call(response) if block
          end
        rescue Error::NotFound
          []
        end

      end

    end
  end
end
