require "spec_helper"

describe MyCalls::Client::StaffMember do

  it "inherits from Base" do
    klass.new.should be_a(MyCalls::Client::Base)
  end

  it "has url" do
    klass.url.should == 'staff_members'
  end

end
