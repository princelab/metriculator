class MsrunsController < ApplicationController
  def show
    @msrun = Msrun.get(params[:id])
  end

  def index
    params[:direction] ||= "asc"
    params[:page] ||= 1
    sort_column = (params[:sort] || "id").to_sym
    sort_object = params[:direction] == "asc" ? sort_column.asc : sort_column.desc
    query = {}
    query.merge!({:order => sort_object})
    #make the query have a search for :like in every property
    Msrun.properties.each do |property|
      query.merge!({ property.name.to_sym.like => params[:search] })
    end
    @sort = sort_object
    @page_number = params[:page]
    @per_page = 8
    @msruns = Msrun.all(query).chunks(@per_page).at(@page_number.to_i - 1)
    @all = Msrun.all
  end

end
