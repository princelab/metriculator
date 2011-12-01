# Controller for Msruns
class MsrunsController < ApplicationController

# This will show an Msrun.  
  def show
    @msrun = Msrun.get(params[:id])
 #   @embed_svg = send_file("/home/ryanmt/Dropbox/coding/rails/metrics_site/testing.svg", disposition: 'inline', type: 'image/svg+xml', stream: false, filename: "#{@msrun.raw_id}.svg")
    if @msrun.graphfile
      @image_path = "public/hplc_graphs/#{Time.now.to_i.to_s}.svg"
      FileUtils.copy(@msrun.graphfile, @image_path)
      @image_path = @image_path.sub("public",'')
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
