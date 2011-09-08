class Comparison
  @@ROOT_COMPARISON_DIRECTORY = AppConfig[:comparison_directory]

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
    res = get_files_at_path(path)
    res.nil? ? nil : res.reject { |f| Dir.exists? f }
  end

  def get_directories_for_relative_path(path)
    res = get_files_at_path(path)
    res.nil? ? nil : res.select { |f| Dir.exist? f }
  end

  def get_files_at_path(path)
    full_path = File.join(self.graph_location, path)
    return nil unless Dir.exist? full_path
    Dir.entries(full_path).reject { |f| f == "." or f == ".." }.map { |e| File.join(full_path, e) }
  end
  private :get_files_at_path

  #Produce a graph of the metrics in this comparison, or return it if it already exists.
  # TODO: check if the graph files already exist?
  def graph
    begin
      FileUtils.mkdir_p self.location_of_graphs unless Dir.exist? self.location_of_graphs
      first = Ms::ComparisonGrapher.slice_matches self.msrun_firsts
      second = Ms::ComparisonGrapher.slice_matches self.msrun_seconds
      files = Ms::ComparisonGrapher.graph_matches first, second, self.location_of_graphs
    rescue StandardError, Rserve::Connection::RserveNotStarted => e
      Rails.logger.error "Graphing failed inside Comparison#graph. Ruh oh! #{e.class}: #{e.message} \n\n\n#{e.backtrace}"
      Alert.create({ :email => false, :show => true, :description => "Error creating the comprasion graphs. Sorry!" })
      Dir.delete self.location_of_graphs if Dir.exist? self.location_of_graphs
    end
  end
end
