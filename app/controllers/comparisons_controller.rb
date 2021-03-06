# Controller for Comparisons
class ComparisonsController < ApplicationController
# Delivers index page
  def index
    params[:direction] ||= 'asc'
    params[:page] ||= 1
    params[:search] ||= {}

    sort_column = ((params[:sort] == "" or params[:sort].nil?) ? "id" : params[:sort]).to_sym
    sort_object = params[:direction] == "asc" ? sort_column.asc : sort_column.desc
    query = {}
    query.merge!({order: sort_object})
    Comparison.properties.each do |property|
      if params[:search].has_key? property.name.to_s
        query.merge!({property.name.to_sym.like => "%#{params[:search][property.name.to_s]}%" })
      end
    end
    @sort = sort_object
    @page_number = params[:page]
    @per_page = 20
    @comparisons = Comparison.all(query).page(@page_number).per(@per_page)
    @all = Comparison.all 
    respond_to do |format|
      format.js {render :index}
      format.html {render :index}
    end
  end

# Delivers a single Comparison
  def show
    @comparison = Comparison.get(params[:id])
  end

# Allows for editing of a single Comparison
  def edit
    @comparison = Comparison.get(params[:id])
  end

# Updates the chosen comparison and responds or redirects
  def update
    @comparison = Comparison.get(params[:id])

    respond_to do |format|
      if @comparison.update(params[:comparison])
        format.html {redirect_to(@comparison, notice: "Comparison was successfully updated") }
        format.json { render :json => {}, :status => :ok }
      else
        format.html { render :action => "edit" }
        format.json { render json: @comparison.errors, status: :unprocessable_entity }
      end
    end
  end

# This is the action which allows for generation of a new comparison.  It uses a fork to spawn a child process which generates the comparison. Notifications will appear when this fails or finishes.  
  def create
    #TODO: first check if one exists already, and redirect to it.
    first_set = get_msruns_from_array_of_ids(params[:comparison1].uniq)
    second_set = get_msruns_from_array_of_ids(params[:comparison2].uniq)

    @comparison = Comparison.new
    @comparison.msrun_firsts = first_set
    @comparison.msrun_seconds = second_set
    @comparison.first_description = params[:first_description]
    @comparison.second_description = params[:second_description]
    @comparison.save
    
# This should capture the windows fork and prevent it.
    if RbConfig::CONFIG['host_os'] === 'mingw32'
      redirect_to :action => "show", :id => @comparison.id
      result = @comparison.graph
      a = Alert.create({ :email => false, :show => true, :description => "DONE WITH COMPARISON #{@comparison.id}" })
    else
      fork do
        result = @comparison.graph
        a = Alert.create({ :email => false, :show => true, :description => "DONE WITH COMPARISON #{@comparison.id}" })
      end
      flash[:notice] = "Comparison started. You will be notified when it completes."
      render :action => "show"
    end

  end

# This is a helper route which helps deliver the comparison graphs from the public folders.  It utilizes the folder structure to help serve the content in a clear manner.
  def get_graph_at_path
    if comparison = Comparison.get(params[:id]) then
      @comparison = comparison
      path = File.join(comparison.location_of_graphs, params[:graph_path])

      if Dir.exist? path
        # turn the directories into the correct paths
        @graph_directories = comparison.get_directories_for_relative_path(params[:graph_path])
        if @graph_directories.nil?
          @graph_directories = []
        else
          @graph_directories = @graph_directories.map { |d| d.gsub(comparison.location_of_graphs.parent.parent, "") }
        end
        @graph_files = comparison.get_files_for_relative_path(params[:graph_path])
        if @graph_files.nil? or @graph_files.empty?
          @graph_files = []
        else
          @graph_files = @graph_files.map { |f| f.gsub(comparison.location_of_graphs.parent.parent, "") }
          subcat = @graph_files.first.split('/')[-2]
          category = @graph_files.first.split('/')[-3]
          @graph_title = [ApplicationController::Name_legend[category.to_s], ApplicationController::Name_legend[subcat]].join (" -- ")
        end
        render :graphs
      else
        render_404
      end

    else
      render_404
    end
  end

# Allows for destruction of a comparison.  This means that you have an option for clearing out old, useless comparisons.
  def destroy
    comparison = Comparison.get(params[:id])
    respond_to do |format|
      format.js { render :nothing => true }
      format.html { redirect_to comparisons_path }
    end
  end
  private

# A helper method to grab Msruns from the database. 
  def get_msruns_from_array_of_ids(ids)
    Msrun.all(:id => ids)
  end
end


