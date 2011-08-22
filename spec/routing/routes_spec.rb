require 'spec_helper'

describe "Routes" do
  describe "Alert routes" do
    it "should route correctly" do
      delete("/alerts/1").should route_to(:controller => "alerts", :action => "destroy", :id => "1")
    end
  end

  describe "Comparison routes" do
    it "should route comparison graphs request to the controller" do
      #yup
      get("/comparisons/1/foo/bar/beans").should route_to(:controller => "comparisons",
                                                         :action => "get_graph_at_path",
                                                         :id => "1",
                                                         :graph_path => "foo/bar/beans")
    end
  end
end
