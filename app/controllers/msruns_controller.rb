class MsrunsController < ApplicationController
  def show
    @msrun = Msrun.get(params[:id])
  end

  def index
    params[:direction] ||= "asc"
    params[:page] ||= 1
    sort_column = (params[:sort] || "id").to_sym
    sort_object = params[:direction] == "asc" ? sort_column.asc : sort_column.desc
    @page_number = params[:page]
    @sort = sort_object
    @per_page = 8
    @msruns = Msrun.all(:order => sort_object).chunks(@per_page).at(@page_number.to_i - 1)
    @all = Msrun.all
  end

end
