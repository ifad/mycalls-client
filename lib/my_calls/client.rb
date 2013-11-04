require "typhoeus"
require "ostruct"
require "active_support/notifications"
require 'active_support/core_ext'
require 'active_support/concern'
require 'dalli'
require 'multi_json'

require "my_calls/client/concerns"
require "my_calls/railtie" if defined?(Rails)

module MyCalls

  class Client

    autoload :Version,      "my_calls/client/version"
    autoload :VERSION,      "my_calls/client/version"
    autoload :Error,        "my_calls/client/error"

    autoload :StaffMember,  "my_calls/client/staff_member"
    autoload :Division,     "my_calls/client/division"
    autoload :Device,       "my_calls/client/device"
    autoload :DeviceType,   "my_calls/client/device_type"

    # The main MyCalls installation.
    #
    # @return [String]
    DEFAULT_OPTIONS  = {
      :base_uri         => "http://webapps.ifad.org/mycalls",
      :timeout          => 2,

      :memcache_server  => 'localhost:11211',
      :memcache_options => {
         :namespace => "my_calls_client",
          :compress => true,
        :expires_in => 15.minutes,
        :serializer => MultiJson
      }
    }

    # The current active client.
    #
    # @return [MyCalls::Client]
    # @private
    @@client = nil

    # Lazy-initializes and return the current {@@client}.
    #
    # @return [MyCalls::Client] The current client.
    def self.client
      @@client ||= new
    end

    # Sets the current {@@client} to +client+.
    #
    # @param  [MyCalls::Client] client The client to set.
    # @return [MyCalls::Client] The new client.
    def self.client=(client)
      @@client = client
    end


    # @return [OpenStruct] The current configuration.
    attr_reader :config

    # Initializes a new client with given options.
    #
    # @param [Hash] options The client options.
    # @option options [String] :base_uri (DEFAULT_BASE_URI) The API base uri.
    def initialize(config = {})
      @config = OpenStruct.new(config.reverse_merge(DEFAULT_OPTIONS))
      @cache  = initialize_cache config
    end

    # @return [String] The current API base uri.
    # @deprecated use config.base_uri instead.
    #
    def base_uri
      ActiveSupport::Deprecation.warn "#{self.class.name}#base_uri is deprecated, use client.config.base_uri instead", caller.tap(&:shift)
      config.base_uri
    end

    # Sends an HTTP Get request to the API endpoint
    # specified by +path+ forcing the Accept type to be JSON.
    #
    # @param  [String] path The path to the URL template to query.
    # @param  [Hash] options The request options, passed to Typhoeus
    # @return [Mixed] The JSON response parsed and converted.
    #
    # @see #request
    def get(path, options = {}, &block)
      (options[:headers] ||= {})['Accept'] = 'application/json'
      MultiJson.load request(:get, path, options, &block)
    end


    # Executes an HTTP request to the API endpoint
    # and returns the result.
    #
    # @param  [String, Symbol] method The HTTP request method (e.g. :get, :post, ...)
    # @param  [String] path The path to the URL template to query.
    # @param  [Hash]   options Options passed to {Typhoeus::Request.new}
    # @return [String] The response body
    #
    # @example Send a HTTP get request
    #   client.request(:get, "/capacities")
    # @example Send a HTTP get request passing a hash of options
    #   client.request(:get, "/capacities", :params => {:foo => 'bar'}, :headers => {'Accept' => 'application/json'})
    #
    # @see http://rubydoc.info/gems/typhoeus/frames
    #
    def request(method, path, options = {})
      url = "#{config.base_uri}/api/#{path}"

      instrument 'request', :method => method, :url => url, :params => options.try(:[], :params) do |instrumentation|
        caching instrumentation, :method => method, :url => url, :options => options do

          options = options.merge(:method => method, :connecttimeout => config.timeout)
          options[:params] = options[:params].to_param if options[:params] # To deal with array parameters

          request = Typhoeus::Request.new(url, options)
          request.on_complete do |response|
            if response.success?
              # No-op
            elsif response.timed_out?
              raise Error::Timeout, "Request timed out after #{config.timeout} seconds"
            elsif response.response_code == 0
              raise Error::Empty, "Empty response from server: #{response.return_message}"
            elsif response.response_code == 404
              raise Error::NotFound, "Resource not found: #{url}"
            else
              raise Error, "HTTP Request failed: #{response.code} - #{response.return_message}"
            end
          end

          request.run.response_body

        end
      end
    end

    # Flushes the configured cache. This is mainly for development purposes.
    #
    def flush_memcached_server
      @cache.flush if @cache
    end

    protected
      def instrument(action, payload, &block)
        ActiveSupport::Notifications.instrument("#{action}.my_calls", payload, &block)
      end

      def caching(instrumentation, key, &block)
        return block.call unless @cache
        key = key.to_s

        if cached = @cache.get(key)
          instrumentation[:cached] = true
          return cached
        end

        block.call.tap do |response|
          @cache.set(key, response) if response
        end
      end

      def log(message)
        if defined?(Rails)
          Rails.logger.warn(message)
        else
          $stderr.puts(message)
        end
      end

      def initialize_cache(options = {})
        cache = Dalli::Client.new(config.memcache_server, config.memcache_options)

        unless cache.stats[config.memcache_server]
          log "[MyCalls::Client] => Cache could not be initialized on server #{config.memcache_server}"
          return nil
        end

        cache
      end

  end

end
