require "spec_helper"
require "my_calls/client/base"

describe MyCalls::Client::Base do

  it "acts as an open struct" do
    base = klass.new
    base.hello.should be_nil
    base.hello = "world"
    base.hello.should == "world"
  end

  describe '#to_json' do
    it "serializes all attributes to JSON" do
      base = klass.new
      base.foo = "bar"
      base.bar = "baz"
      base.to_json.should == MyCalls::Client::Serializer.dump(:foo => 'bar', :bar => 'baz')
    end
  end

  describe '#as_json' do
    it "returns the defined attributes as an Hash" do
      base = klass.new
      base.foo = "bar"
      base.bar = "baz"
      base.as_json.should == {:foo => "bar", :bar => "baz"}
    end
  end

  describe "#client" do
    it "delegates to MyCalls::Client" do
      mock(MyCalls::Client).client
      klass.new.client
    end
  end

  describe "#client=" do
    it "delegates to MyCalls::Client" do
      object = Object.new
      mock(MyCalls::Client).client=(object)
      klass.new.client = object
    end
  end


  describe ".client" do
    it "delegates to MyCalls::Client" do
      mock(MyCalls::Client).client
      klass.client
    end
  end

  describe "#client=" do
    it "delegates to MyCalls::Client" do
      object = Object.new
      mock(MyCalls::Client).client=(object)
      klass.client = object
    end
  end


  describe "#fetched!" do
    it "flags the record as fetched" do
      klass.new.tap do |record|
        record.fetched.should be_nil
        record.fetched!
        record.fetched.should be_true
      end
    end

    it "returns self" do
      klass.new.tap do |record|
        record.fetched!.should be(record)
      end
    end
  end

  describe "#fetched?" do
    it "returns if the record is fetched" do
      klass.new.tap do |record|
        record.fetched?.should be_false
        record.fetched!
        record.fetched?.should be_true
      end
    end
  end


  describe ".identify" do
    it "returns the given id if object is an id" do
      klass.identify(10).should == 10
    end

    it "extracts and returns the instance id if object is an id" do
      klass.identify(klass.new(:id => 1)).should == 1
      klass.identify(klass.new(:id => nil)).should be_nil
    end

    it "raises ArgumentError if object is an unsupported instance" do
      lambda { klass.identify("hello") }.should raise_error(ArgumentError)
    end

    ChildClass = Class.new(MyCalls::Client::Base)

    it "raises ArgumentError if object class is not an ancestor of current class" do
      lambda do
        ChildClass.identify(klass.new(:id => 20))
      end.should raise_error(ArgumentError)
    end

    it "doesn't raises ArgumentError if object class is an ancestor of current class" do
      lambda do
        klass.identify(ChildClass.new(:id => 20)).should == 20
      end.should_not raise_error
    end
  end

end
