class Comparison
  #TODO: get the comparisons
  COMPARISON_DIRECTORY = ""
  include DataMapper::Resource
  property :id, Serial

  property :start_timestamp, DateTime
  property :end_timestamp, DateTime

  property :taxonomy, String
  property :graph_location, FilePath, :default => lambda { |comp, property| File.join(COMPARISON_DIRECTORY, comp.id) }

  has n, :firsts
  has n, :msrun_firsts, 'Msrun', :through => :firsts, :via => :msrun

  has n, :seconds
  has n, :msrun_seconds, 'Msrun', :through => :seconds, :via => :msrun

  #Produce a graph of the metrics in this comparison, or return it if it already exists.
  def graph
    grapher = ::Ms::ComparisonGrapher.new
    first = grapher.slice_matches self.msrun_firsts
    second = grapher.slice_matches self.msrun_seconds
    files = grapher.graph_matches first, second
  end

  #how to dynamically generate the routes from the comparison path?
end
