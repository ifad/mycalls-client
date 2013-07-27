require "spec_helper"

describe MyCalls::Client::DeviceType do

  it "inherits from Base" do
    klass.new.should be_a(MyCalls::Client::Base)
  end

  it "has url" do
    klass.url.should == 'device_types'
  end

end
