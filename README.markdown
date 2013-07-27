# MyCalls Client

A Ruby client for the [MyCalls](http://webapps.ifad.org/mycalls) REST API.

## Getting Started

To get started, choose the class corresponding the resource you want to find, and use one of the available finder method.

For instance, to get a list of all devices, use

    MyCalls::Client::Device.find_all
    # => [#<MyCalls::Client::Device>, #<MyCalls::Client::Device>, ...]

The method reflect MyCalls API and supports all existing filters.

    MyCalls::Client::Device.find_all(:staff_member_id => "12345")
    # => [#<MyCalls::Client::Device>, #<MyCalls::Client::Device>, ...]

    MyCalls::Client::Device.find_all(:active => true)
    # => [#<MyCalls::Client::Device>, #<MyCalls::Client::Device>, ...]

To find a specific resource, use the `#find` method and pass the resource identifier.
The method returns the record if it exists, `nil` otherwise.

    MyCalls::Client::Device.find(1)
    # => #<MyCalls::Client::Device>

    MyCalls::Client::Device.find(10_000)
    # => nil

The returned record acts as an open struct. You can query its properties as you would do with an ActiveRecord object.

    u = MyCalls::Client::StaffMember.find(1)
    # => #<MyCalls::Client::StaffMember>

    u.id      # => 1
    u.email   # => s.carletti@ifad.org

The API is consistent across all classes.


## Customizing the HTTP Request

The HTTP client is represented by the `MyCalls::Client` itself. The class variable `@@client` holds the active HTTP client.

    MyCalls::Client.client
    # => #<MyCalls::Client:0x1016e6750 @base_uri="http://ifad-munus.heroku.com/api/">

The current client is automatically initialized the first time a client is requested.

To customize the client settings, create a custom client and assign is as the active client.

    MyCalls::Client.client = MyCalls::Client.new(:base_uri => "http://localhost:3000")

Please note that the client instance is shared between all `MyCalls::Client` classes. You cannot configure a different client for a specific class.

    MyCalls::Client::Device.client = MyCalls::Client.new(:base_uri => "http://localhost:3000")
    # => #<MyCalls::Client:0x1016e6700 @base_uri="http://localhost:3000">

    MyCalls::Client::StaffMember.client = MyCalls::Client.new(:base_uri => "http://example.org")
    # => #<MyCalls::Client:0x1016e6750 @base_uri="http://example.org">

    MyCalls::Client::Device.client
    # => #<MyCalls::Client:0x1016e6750 @base_uri="http://example.org">

## Documentation

This library is documented with [YARD](http://yardoc.org/). To generate the documentation install yard and run the `yard` task.

    $ gem install yard
    $ cd /path/to/mycalls-client
    $ rake yard

If you are contributing to the library, use the yard server feature.

    $ cd /path/to/mycalls-client
    $ yard server --reload
    >> YARD 0.6.3 documentation server at http://0.0.0.0:8808
    >> Mongrel web server (running on Rack)
    >> Listening on 0.0.0.0:8808, CTRL+C to stop
