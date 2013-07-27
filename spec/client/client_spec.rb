require "spec_helper"

describe MyCalls::Client do

  describe "VERSION" do
    it "is equivalent to Version::STRING" do
      klass::VERSION.should be(klass::Version::STRING)
    end
  end


  describe ".client=" do
    it "sets the client to the new value" do
      client = klass.new
      klass.client = client
      current_client.should be_equal(client)
    end

    it "sets the client to nil" do
      klass.client = nil
      current_client.should be_nil
    end
  end

  describe ".client" do
    it "returns the current client value" do
      client = klass.new
      klass.client = client
      klass.client.should be_equal(client)
    end

    it "initializes a new client if current client is nil" do
      klass.client = nil
      klass.client.should be_a(klass)
    end
  end


  describe "#initialize" do
    it "accepts zero arguments" do
      lambda { klass.new }.should_not raise_error
    end

    it "defaults base_uri" do
      klass.new.config.base_uri.should == klass::DEFAULT_OPTIONS[:base_uri]
    end

    it "accepts a hash of options" do
      lambda { klass.new(:foo => "bar") }.should_not raise_error
    end

    it "accepts an option to customize base_uri" do
      klass.new(:base_uri => "http://localhost").config.base_uri.should == "http://localhost"
    end
  end


  describe "#request" do
    let(:client) { klass.new }
    let(:method) { :get }

    it "joins url with base_uri and delegates the request to Typhoeus" do
      Typhoeus.stub("#{klass.client.config.base_uri}/api/categories").
        and_return(Typhoeus::Response.new(code: 200, body: 'foo'))

      client.request(:get, "categories").should == 'foo'
    end

    it "passes the arguments to the Typhoeus" do
      Typhoeus.stub("#{client.config.base_uri}/api/messages", :foo => 'bar').
        and_return(Typhoeus::Response.new(code: 200, body: 'baz'))

      client.request(:get, "messages", { :foo => "bar" }).should == 'baz'
    end

    it "supports array parameters" do
      Typhoeus.stub("#{client.config.base_uri}/api/foobar", :params => 'foo%5B%5D=bar&foo%5B%5D=baz').
        and_return(Typhoeus::Response.new(code: 200, body: 'yes'))

      client.request(:get, "foobar", { :params => {:foo => %w( bar baz )} }).should == 'yes'
    end

    it "raises Error::Timeout when requests time out" do
      pending
    end
  end

  describe "#get" do
    it "delegates the request to #request" do
      client = klass.new
      mock(client).request(:get, "categories", anything) { "" }

      client.get("categories")
    end

    it "passes the arguments to #request" do
      client = klass.new
      mock(client).request(:get, "categories", hash_including(:foo => "bar")) { "" }

      client.get("categories", { :foo => "bar" })
    end

    it "adds the :accept => :json header" do
      client = klass.new
      mock(client).request(:get, "categories", hash_including(:headers => {'Accept' => 'application/json'})) { "" }

      client.get("categories", { :foo => "bar" })
    end

    it "forces the :accept => :json header" do
      client = klass.new
      mock(client).request(:get, "categories", hash_including(:headers => {'Accept' => 'application/json'})) { "" }

      client.get("categories", { :headers => {'Accept' => 'application/vnd.ms-excel'} })
    end

    it "treats the response as JSON and parses the input" do
      client = klass.new
      mock(client).request(:get, "categories", hash_including({})) { '{"name":"hello","id":1}' }

      hash = client.get("categories", { :accept => "html" })
      hash.should be_a(Hash)
      hash["id"].should == 1
      hash["name"].should == "hello"
    end
  end


  private

    def current_client
      klass.send(:class_variable_get, :@@client)
    end

end
