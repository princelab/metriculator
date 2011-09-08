require 'spec_helper'

describe MetricController do

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
    it 'contains an overview of a metric' do 
      get :show
      response.should have_selector('title', content: "Metric Overview")
    end
  end # GET show

end
