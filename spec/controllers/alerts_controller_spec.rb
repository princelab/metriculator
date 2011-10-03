require 'spec_helper'

describe AlertsController do
  describe "#destroy" do
    it "should destroy the created alert" do
      prep_count = Alert.all(:show => true).size
      alert = FactoryGirl.create :alert
      delete :destroy, :id => alert.id
      Alert.all(:show => true).size.should == prep_count
    end
  end

end
