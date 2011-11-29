require 'spec_helper'

describe ComparisonsController do
  render_views

  FactoryGirl.create(:msrun)
  FactoryGirl.create(:msrun)
  FactoryGirl.create(:msrun)

  describe "#show" do
    it "should return a comparison if one of the given id exists"
  end

  describe "#put" do
    it "should create a new comparison comparing the two sets of Msruns"
  end
  describe "known_trends" do 
    it "should choose to not show any arrow if false" do 
      get :get_graph_at_path, :id => 1, :graph_path => "chromatography/wide_rt_differences_for_ids_4_min" 
      response.body.should_not include("up_arrow.svg")
      response.body.should_not include("down_arrow.svg")
    end
    it "should show an up arrow if 'up'" do 
      get :get_graph_at_path, :id => 1, :graph_path => "peptide_ids/peptide_counts" 
      response.body.should include("up_arrow.svg")
    end
    it "should show a down arrow if 'down'" do 
      get :get_graph_at_path, :id => 1, :graph_path => "chromatography/peak_width_at_half_height_for_ids" 
      response.body.should include "down_arrow.svg"

    end
  end
end
