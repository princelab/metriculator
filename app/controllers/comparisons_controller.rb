class ComparisonsController < ApplicationController
  def index
    @comparisons = Comparison.all
  end

  def show
  end

  def create
  end
end
