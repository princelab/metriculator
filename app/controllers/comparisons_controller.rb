class ComparisonsController < ApplicationController
  def index
    @comparisons = Comparison.all
  end

  def show
    @comparison = Comparison.get(params[:id])
  end

  def create
    #TODO: first check if one exists already, and redirect to it.
    first_set = get_msruns_from_array_of_ids(params[:comparison1].uniq)
    second_set = get_msruns_from_array_of_ids(params[:comparison2].uniq)

    comp = Comparison.new
    comp.msrun_firsts = first_set
    comp.msrun_seconds = second_set
    comp.save

    fork do
      result = comp.graph
      puts "DONE GRAPHING"
      a = Alert.create({ :email => false, :show => true, :description => "DONE WITH COMPARISON #{comp.id}" })
    end

    flash[:notice] = "Comparison started. You will be notified when it completes."
    redirect_to :action => "show", :id => comp.id
  end

  def get_graph_at_path
    if comparison = Comparison.get(params[:id]) then
      path = File.join(comparison.location_of_graphs, params[:graph_path])

      if Dir.exist? path
        # turn the directories into the correct paths
        @graph_directories = comparison.get_directories_for_relative_path(params[:graph_path])
        p @graph_directories
        if @graph_directories.nil?
          @graph_directories = []
        else
          @graph_directories = @graph_directories.map { |d| d.gsub(comparison.location_of_graphs.parent.parent, "") }
        end
        @graph_files = comparison.get_files_for_relative_path(params[:graph_path])
        if @graph_files.nil?
          @graph_files = []
        else
          @graph_files = @graph_files.map { |f| f.gsub(comparison.location_of_graphs.parent.parent, "") }
        end
        render :graphs
      else
        render_404
      end

    else
      render_404
    end
  end

  private
  def get_msruns_from_array_of_ids(ids)
    ret = ids.map do |id|
      Msrun.get(id)
    end
    ret
  end
end


