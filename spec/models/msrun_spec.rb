require 'spec_helper'

describe Msrun do
  it "should be valid" do
    run = FactoryGirl.build(:msrun)
    run.raw_id.should == "123456"
  end
end
