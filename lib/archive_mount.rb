#This class provides the utility for organizing the file structure and handling the archive as a Mounted location, simplifying the use elsewhere in the library
module Ms
  class ArchiveMount
    class << self
      # Make a new ArchiveMount which will set the new location for the archive, and knows how to find things.
      def initialize(msrun)
	@msrun = msrun
	define_location
      end
      @@build_directories = ['init', 'metrics', 'ident', 'quant', 'results', 'graphs', 'mzML', 'archive' ]
      # Builds the archive directory structure in the root, according to this model:
      #  root = ..group/user/YYYYMM/experiment_name/
      #	./init/ Files pertinent to the initialization of the data such as the TUNE and METHOD and UPLC files.
      #	./metrics/ All the metrics stuff
      #	./ident/ identification analysis
      #	./quant/ quantification analysis
      #	./results/ Results of the analysis
      #	./graphs/ graphs of the Metrics and UPLC results (SO the HTML will rest here!)
      #	./samplename(s).RAW
      #	./mzML/ The mzXML and mzML files
      #	./config.yml
      #	./archive/ 	ANY other log files, or previous config files that might be stored
      # @param None
      # @return Nothing specific yet ### TODO
      def build_archive # @location == LOCATION(group, user, mtime, experiment_id)
  # Dir.chdir(
	# cp the config file from the higher level down
	@@build_directories.each do |dir|
	  mkdir dir
	end
	# Find a config file and move it down to this directory... right?

      end
      # Moves the files to the location by calling {#define_location}, {#build_archive}, and ... 
      # @param None
      # @return Nothing specific yet ### TODO
      def to_mount
	build_archive
      end

      def archive # MOVE THE FILES OVER TO THE LOCATION
	files = @msrun[0..6]
	config = load_runconfig(@location)
	
      end
      # This defines the location for the archived directory and can be used by a File.join command to generate a FilePath
      # location = (group, user, mtime, experiment_name)
      # @param None, uses #msrun initialized
      # @return location array
      def define_location
	@location = [@msrun.group, @msrun.user, File.mtime(@msrun.rawfile), @msrun.rawid]
  # TODO this should be updating the model to contain the new locations, relative to the path
	@msrun.archive_location = @location
      end
    end
  end
end # Module
