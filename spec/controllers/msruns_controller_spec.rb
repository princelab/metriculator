require 'spec_helper'

describe MsrunsController do

  describe "GET 'show'" do
    it "should be successful" do
      run = FactoryGirl.create :msrun
      get :show, :id => run.id
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
      # page.should have_content("Msruns")
      response.should be_success
    end
  end
end
