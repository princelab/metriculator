class MsrunsController < ApplicationController
  def show
    @msrun = Msrun.get(params[:id])
  end

  def index
    params[:direction] ||= "asc"
    params[:page] ||= 1
    params[:search] ||= ""
    #default to sorting based on the id column if nothing is given in sort
    sort_column = ((params[:sort] == "" or params[:sort].nil?) ? "id" : params[:sort]).to_sym
    sort_object = params[:direction] == "asc" ? sort_column.asc : sort_column.desc
    query = {}
    query.merge!({:order => sort_object})
    #make the query have a search for :like in every property
    # nope, that won't work. It means **everything** would have to be LIKE the search param
    # Msrun.properties.each do |property|
    #   query.merge!({ property.name.to_sym.like => params[:search] })
    # end
    query.merge!({ :raw_id.like => "%#{params[:search]}%" })
    @sort = sort_object
    @page_number = params[:page]
    @per_page = 8
    # @msruns = Msrun.all(query).chunks(@per_page).at(@page_number.to_i - 1)
    @msruns = Msrun.all(query)
    @all = Msrun.all
    respond_to do |format|
      format.js { puts "JAVASCRIPTS????"; render :index }
      format.html { puts "HTML???????"; render :index }
    end
  end

end
