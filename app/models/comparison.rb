class Comparison
  #TODO: get the archiver directory?
  @@ROOT_COMPARISON_DIRECTORY = File.expand_path(File.join("public", "comparisons"), Rails.root)

  # Where the comparisons directory is on the filesystem
  include DataMapper::Resource
  property :id, Serial

  property :start_timestamp, DateTime
  property :end_timestamp, DateTime

  property :taxonomy, String
  property :graph_location, FilePath

  has n, :firsts
  has n, :msrun_firsts, 'Msrun', :through => :firsts, :via => :msrun

  has n, :seconds
  has n, :msrun_seconds, 'Msrun', :through => :seconds, :via => :msrun

  def location_of_graphs
    if self.graph_location.nil?
      self.graph_location = File.join(@@ROOT_COMPARISON_DIRECTORY, self.id.to_s)
      self.save
    end
    self.graph_location
  end

  def location_of_graphs=(loc)
    self.graph_location = loc
    self.save
  end

  def get_files_for_relative_path(path)
    return nil unless File.exist? File.join(self.graph_location, path)
  end

  #Produce a graph of the metrics in this comparison, or return it if it already exists.
  def graph
    begin
      first = Ms::ComparisonGrapher.slice_matches self.msrun_firsts
      second = Ms::ComparisonGrapher.slice_matches self.msrun_seconds
      files = Ms::ComparisonGrapher.graph_matches first, second
    rescue
      logger.error "Graphing failed inside Comparison#graph. Ruh oh!"
      Alert.create({ :email => false, :display => true, :message => "Error creating the comprasion graphs. Sorry!" })
    end
  end
end
