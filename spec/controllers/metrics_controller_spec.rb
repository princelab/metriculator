require 'spec_helper'

describe MetricsController do

  describe "GET #index" do
    it "should be successful" do
      get :index
      response.should be_success
    end

  end # GET show

  describe "GET show" do
    it 'contains an overview of a metric' do
      get :show, :id => 1
      response.should have_selector('title')
    end
  end
end
