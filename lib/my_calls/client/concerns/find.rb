module MyCalls
  class Client
    module Concerns

      module Find
        extend ActiveSupport::Concern

        include Url

        module ClassMethods

          # Gets the list of all objects.
          #
          # Parameters are sent to MyCalls in order to filter
          # the list according to given preferences.
          #
          # @param  [Hash] params Optional parameters to filter the query.
          # @return [Array<MyCalls::Client::StaffMember>]
          #
          # @example Select all objects
          #   StaffMember.all
          #   # => [#<StaffMember>, #<StaffMember>, ...]
          #
          def find_all(params = {})
            instantiate_collection client.get(self.url, :params => params)
          end
          alias :all :find_all

          # Searches and returns the person matching given +id+.
          #
          # @param  [Fixnum, #to_s] id_or_email The record id or email.
          # @return [MyCalls::Client::StaffMember] If an person with given id exists.
          # @return [nil] If an person with given id doesn't exist.
          #
          # @example Record 1 exists
          #   StaffMember.find(1)
          #   # => #<StaffMember>
          # @example Record 100 doesn't exist
          #   StaffMember.find(100)
          #   # => nil
          #
          # @example Find record by id
          #   StaffMember.find("1")
          #   # => #<StaffMember>
          # @example Find record by email
          #   StaffMember.find("example@ifad.org")
          #   # => #<StaffMember>
          #
          def find(id_or_email)
            instantiate_record client.get("#{self.url}/#{id_or_email}")
          rescue Error::NotFound
            nil
          end
          alias :show :find_all

        end

      end

    end
  end
end
