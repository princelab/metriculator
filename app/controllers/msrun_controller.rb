class MsrunController < ApplicationController
  def show
    @msrun = Msrun.get(params[:id])
  end

  def index
    params[:direction] ||= "asc"
    sort_column = (params[:sort] || "id").to_sym
    sort_object = params[:direction] == "asc" ? sort_column.asc : sort_column.desc
    @msruns = Msrun.all(:order => [sort_object])
  end

  def get_matching_for_filter_criteria
    @msruns = Msrun.all
    #TODO
    #render them back as HTML
  end

end
