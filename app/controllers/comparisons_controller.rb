class ComparisonsController < ApplicationController
  def index
    @comparisons = Comparison.all
  end

  def show
  end

  def create
    puts "In ComparisonsController#create. Here are the params."
    pp params
  end
end
