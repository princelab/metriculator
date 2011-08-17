require 'spec_helper'

describe AlertsController do


  describe "#destroy" do
    it "should destroy the created alert" do
      alert = FactoryGirl.create :alert
      delete :destroy, :id => alert.id
      Alert.count.should == 0
    end
  end

end
