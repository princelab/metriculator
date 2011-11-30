require 'spec_helper'

describe Msrun do
  before :each do 
    @run = FactoryGirl.build(:msrun)
  end
  after :each do 
    @run.destroy!
  end
  it "should be valid" do
    @run.raw_id.should == "123456"
  end
end
