require 'spec_helper'

describe MsrunController do

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end
  describe "GET 'index'" do 
    it 'should succeed' do 
      get :index
      response.should be_success
    end
    it 'contains a list of metrics' do 
      get :index
      response.should have_selector('title', content: "Msruns"
    end
end
