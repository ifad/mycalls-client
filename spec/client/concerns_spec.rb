require "spec_helper"
require 'my_calls/client/base'
require 'my_calls/client/concerns'

describe 'MyCalls::Client::Concernas' do

  before do
    class MyCalls::Client::Foo < MyCalls::Client::Base
      include MyCalls::Client::Concerns::Find
      include MyCalls::Client::Concerns::Search
      include MyCalls::Client::Concerns::Magic

      self.url = 'foos'
    end
  end

  let(:klass) { MyCalls::Client::Foo }

  describe ".find_all" do
    it "returns an array of Foo" do
      mock(MyCalls::Client.client).get("foos", :params => {}) { json_fixture("foos/index.json") }
      r = klass.all
      r.should be_a(Array)
      r.should have(4).items
    end

    it "appends the params in the request querystring" do
      mock(MyCalls::Client.client).get("foos", hash_including(:params => { :foo => "bar" })) { json_fixture("foos/index.json") }
      r = klass.all(:foo => "bar")
      r.should have(4).items
    end
  end

  describe ".find" do
    it "requests the person with given id" do
      mock(MyCalls::Client.client).get("foos/1") { json_fixture("foos/show.json") }
      klass.find(1)
      mock(MyCalls::Client.client).get("foos/1") { json_fixture("foos/show.json") }
      klass.find("1")
    end

    context "when the person exists" do
      it "returns the Foo" do
        mock(MyCalls::Client.client).get("foos/1") { json_fixture("foos/show.json") }
        r = klass.find("1")
        r.should be_a(MyCalls::Client::Foo)
        r.id.should == 1
      end
    end

    context "when the person doesn't exist" do
      it "returns nil" do
        mock(MyCalls::Client.client).get("foos/2000") { raise MyCalls::Client::Error::NotFound.new }
        r = klass.find("2000")
        r.should be_nil
      end
    end

  end

  describe ".search" do
    context "when there is a match" do
      it "returns an Foo Array" do
        mock(MyCalls::Client.client).get("foos/search", :params => {:q => 'foo'}) { json_fixture("foos/index.json") }
        r = klass.search('foo')
        r.should be_a(Array)
        r.all? {|u| u.kind_of? MyCalls::Client::Foo }.should be_true
      end
    end

    context "when trere is no match" do
      it "returns []" do
        mock(MyCalls::Client.client).get("foos/search", :params => {:q => 'bar'}) { [] }
        r = klass.search("bar")
        r.should == []
      end
    end
  end

  describe ".bars" do
    it "requests the bars for the staff_member with given id" do
      mock(MyCalls::Client.client).get("foos/1") { json_fixture("foos/show.json") }
      mock(MyCalls::Client.client).get("foos/1/bars", params: nil) { json_fixture("foos/bars.json") }
      r = klass.find(1)
      b = r.bars
      b.should be_a(Array)
      b.should have(4).items
    end
  end

  describe "#baz" do
    it "requests the foos scoped under baz" do
      mock(MyCalls::Client.client).get("foos/baz", params: nil) { json_fixture("foos/index.json") }
      r = klass.baz
      r.should be_a(Array)
      r.should have(4).items
    end
  end
end
