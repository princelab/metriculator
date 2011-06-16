class MsrunController < ApplicationController
  def show
    @msrun = Msrun.get(params[:id])
  end

  def index
    @msruns = Msrun.all
  end

  def get_matching_for_filter_criteria
    @msruns = Msrun.all
    #TODO
    #render them back as HTML
  end

end
