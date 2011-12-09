require 'spec_helper'

describe ComparisonsController do
  #render_views

  a = 3.times.map { FactoryGirl.create(:msrun) }

  describe "#show" do
    it "should return a comparison if one of the given id exists"
  end

  describe "#put" do
    it "should create a new comparison comparing the two sets of Msruns"
  end
  describe "known_trends" do 
    it "should choose to not show any arrow if false" do 
      get :get_graph_at_path, :id => 1, :graph_path => "chromatography/wide_rt_differences_for_ids_4_min" 
      response.status.should == 200
      response.body.should_not include("up.png")
      response.body.should_not include("down.png")
    end
    it "should show an up arrow if 'up'" do 
      get :get_graph_at_path, :id => 1, :graph_path => "peptide_ids/peptide_counts" 
      response.body.should include("up.png")
    end
    it "should show a down arrow if 'down'" do 
      get :get_graph_at_path, :id => 1, :graph_path => "chromatography/peak_width_at_half_height_for_ids" 
      response.body.should include "down.png"

    end
  end
  a.each {|b| b.destroy! }
end
