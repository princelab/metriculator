# Controller for Msruns
class MsrunsController < ApplicationController

# This will show an Msrun.  
  def show
    @msrun = Msrun.get(params[:id])
    if @msrun.graphfile
      if File.extname(@msrun.graphfile) == '.yml'
        data = YAML.load_file(@msrun.graphfile)
        @h = LazyHighCharts::HighChart.new('hplc_plot') do |f|
          f.option[:title][:text] = 'UPLC pressure trace'
          f.option[:chart][:plotBackgroundColor] = nil
          f.options[:chart][:defaultSeriesType] = 'line'
          f.series(name: "Qa (nL/min)", data: data[:qa], marker: {enabled: false}, turboThreshold: 10)
          f.series(name: "Qb (nL/min)", data: data[:qb], marker: {enabled: false}, turboThreshold: 10 )
          f.series(name: "Pc (psi)", data: data[:pc], yAxis: 1, marker: {enabled: false}, turboThreshold: 10)
          f.yAxis([{ title: { text: "Flowrate (nL/min)", style: { color: "#4572a7" } }, min: 0}, {title: { text: 'Pressure (psi)', style: { color: "#89A54E" } } , opposite: true}])
        end
      end
    end
  end

# This shows the lists of metrics, and also provides sorting functions, pagination, and allows for generation of comparisons. 
  def index
    params[:direction] ||= "asc"
    params[:page] ||= 1
    params[:search] ||= {}
    params[:search][:rawtime] ||= {}

    #default to sorting based on the id column if nothing is given in sort
    sort_column = ((params[:sort] == "" or params[:sort].nil?) ? "id" : params[:sort]).to_sym
    sort_object = params[:direction] == "asc" ? sort_column.asc : sort_column.desc
    query = {}
    query.merge!({:order => sort_object})

    Msrun.properties.each do |property|
      #The rawtime parameter is a hash: { start: SOME_DATE, end: SOME_OTHER_DATE }
      # so we handle it separately
      if property.name.to_s == "rawtime"
        #Malformed dates to DateTime.parse throw an Argument error
        begin
          start = params["search"]["rawtime"].fetch("start", "")
          start = DateTime.parse(start) unless start.empty?
        rescue ArgumentError
          start = ""
        end

        begin
          after = params["search"]["rawtime"].fetch("end", "")
          after = DateTime.parse(after) unless after.empty?
        rescue ArgumentError
          after = ""
        end

        if start.kind_of? DateTime
          if after.kind_of? DateTime
            query.merge!({ property.name.to_sym.lte => after, property.name.to_sym.gte => start })
          else
            query.merge!({ property.name.to_sym.gte => start })
          end
        else
          if after.kind_of? DateTime
            query.merge!({ property.name.to_sym.lte => after })
          end
        end
      elsif params[:search].has_key? property.name.to_s
        query.merge!({ property.name.to_sym.like => "%#{params[:search][property.name.to_s]}%" })
      end
    end

    @sort = sort_object
    @page_number = params[:page]
    @per_page = 20
    # @msruns = Msrun.all(query).chunks(@per_page).at(@page_number.to_i - 1)
    @msruns = Msrun.all(query).page(@page_number).per(@per_page)
    @all = Msrun.all
    respond_to do |format|
      format.js { render :index }
      format.html { render :index }
    end
  end
end
