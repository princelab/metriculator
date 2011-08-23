require 'spec_helper'

describe "Comparisons" do
  describe "create a new comparison" do
    it "should show a flash message on success" do

      visit msruns_path
      click_button("Add To Comparison Set One")
      click_button("Add To Comparison Set Two")
      click_button("Compare")
      page.should have_content("started")
      response.status.should be(200)
    end
  end
end
