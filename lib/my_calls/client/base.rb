require 'ostruct'

module MyCalls
  class Client

    class Base < OpenStruct

      if method_defined? :id
        undef :id
      end


      # Initializes a new instance from given +hash+.
      #
      # It overrides the default OpenStruct initializer
      # to make sure associations passed as Hash are correctly
      # initialized as objects.
      #
      # @param  [Hash, nil] hash
      #
      def initialize(hash = nil)
        super({})

        if hash
          hash.each do |key, value|
            new_ostruct_member(key)
            send("#{key}=", value)
          end
        end
      end

      # Serializes all attributes in the JSON format
      #
      # @return [String]
      #
      def to_json
        Serializer.dump(@table)
      end

      # ActiveSupport +as_json+ interface.
      #
      # @return [Hash] the defined attributes.
      #
      def as_json(options = nil)
        @table
      end


      # Delegates to {MyCalls::Client.client}.
      #
      # @return [MyCalls::Client] The current client.
      def client
        self.class.client
      end

      # Delegates to {MyCalls::Client.client=}.
      #
      # @param  [MyCalls::Client] client The client to set.
      # @return [MyCalls::Client] The new client.
      def client=(client)
        self.class.client=(client)
      end

      # Delegates to {MyCalls::Client.client}.
      #
      # @return [MyCalls::Client] The current client.
      def self.client
        Client.client
      end

      # Delegates to {MyCalls::Client.client=}.
      #
      # @param  [MyCalls::Client] client The client to set.
      # @return [MyCalls::Client] The new client.
      def self.client=(client)
        Client.client=(client)
      end


      # @return [Boolean, nil] The value of the +@fetched+ flag.
      attr_reader :fetched

      # Flag this record as fetched.
      # This flag indicates the record has been loaded from the server.
      #
      # @return [self]
      # @see #fetched?
      def fetched!
        @fetched = true
        self
      end

      # Checks if this record is fetched.
      #
      # @return [Boolean]
      # @see #fetched?
      def fetched?
        !!fetched
      end


      # Guesses if +object+ is an id or an instance
      # and attempts to always return the record id.
      #
      # @param  [Fixnum, Base] The record to identify.
      # @return [Fixnum] The record id.
      #
      # @example Given an id, returns the id.
      #   Capacity.identify(1)
      #   # => 1
      #
      # @example Given a record, returns the id.
      #   Capacity.identify(Capacity.find(20))
      #   # => 20
      #
      def self.identify(object)
        case object
          when Fixnum
            object
          when self
            object.id
          else
            raise ArgumentError, "Unable to extract the id from an instance of #{object.class}"
        end
      end


      private

        def attribute_write(name, value)
          name = name.to_sym
          modifiable[name] = value
        end

        def attribute_read(name)
          name = name.to_sym
          @table[name]
        end

        def attribute_exist?(name)
          name = name.to_sym
          @table.has_key?(name)
        end


        # @api internal
        # @private
        def associated_attribute_setter(klass, name, value)
          case value
            when nil, klass
              attribute_write(name, value)
            when Hash
              attribute_write(name, klass.instantiate_record(value))
            else
              raise ArgumentError, "Unable to set ##{name}= from `#{value.class}'"
          end
        end

        # @api internal
        # @private
        def associated_attribute_getter(klass, name, options = {})
          options[:reload]    ||= false
          options[:autofetch] ||= false

          if options[:reload] || (options[:autofetch] && !attribute_exist?(name))
            attribute_write(name, self.class.send(name, id))
          end
          attribute_read(name)
        end


      protected

        def self.instantiate_collection(collection)
          collection.collect! { |record| instantiate_record(record) }
        end

        def self.instantiate_record(record)
          # FIXME: MyCalls should raise 404 instead of returning a null JSON response.
          return nil if record.nil?

          new(record).tap do |resource|
            resource.fetched!
          end
        end

    end

  end
end
