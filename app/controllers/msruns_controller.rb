class MsrunsController < ApplicationController
  def show
    @msrun = Msrun.get(params[:id])
  end

  def index
    params[:direction] ||= "asc"
    params[:page] ||= 1
    sort_column = (params[:sort] || "id").to_sym
    sort_object = params[:direction] == "asc" ? sort_column.asc : sort_column.desc
    @msruns = Msrun.all.page(params[:page], :per_page => 8, :order => sort_object)
    @page_number = params[:page]
    @sort = sort_object
    @per_page = 8
  end

  def get_matching_for_filter_criteria
    @msruns = Msrun.all
    #TODO
    #render them back as HTML
  end

end
