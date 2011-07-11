require 'spec_helper'

describe Metric do
  let(:metric) { FactoryGirl.create(:metric) }
  it "should have an msrun parent" do
    metric.msrun.should_not be_nil
  end
end
