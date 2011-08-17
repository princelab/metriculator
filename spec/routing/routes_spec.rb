require 'spec_helper'

describe "Routes" do
  describe "Alert routes" do
    it "should route correctly" do
      delete("/alerts/1").should route_to(:controller => "alerts", :action => "destroy", :id => "1")
    end
  end
end
