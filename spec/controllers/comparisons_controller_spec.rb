require 'spec_helper'

describe ComparisonsController do

  FactoryGirl.create(:msrun)
  FactoryGirl.create(:msrun)
  FactoryGirl.create(:msrun)

  describe "#show" do
    it "should return a comparison if one of the given id exists"
  end

  describe "#put" do
    it "should create a new comparison comparing the two sets of Msruns"

  end
end
