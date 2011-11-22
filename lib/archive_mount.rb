#This class provides the utility for organizing the file structure and handling the archive as a Mounted location, simplifying the use elsewhere in the library
module Ms
  class ArchiveMount
    class << self
      # Make a new ArchiveMount which will set the new location for the archive, and knows how to find things.
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
	restore_dir = Dir.pwd
        @mount_dir ||= ::ArchiveRoot
	FileUtils.mkdir_p(File.join(@mount_dir, @location))
        Dir.chdir(File.join(@mount_dir, @location))
        # cp the config file from the higher level down
        @@build_directories.each do |dir|
          FileUtils.mkdir dir unless Dir.exist?(dir)
        end
	Dir.chdir(restore_dir)
        # Find a config file and move it down to this directory... right?
      end
      # Moves the files to the location by calling {#define_location}, {#build_archive}, and ... 
      # @param None
      # @return Nothing specific yet ### TODO
      def send_to_mount(object)
	Messenger.setup
        @msrun = object
        define_location unless @location
        build_archive
        archive
        Messenger.add_todo(relative_path(@msrun.rawfile))
      end

      def archive # MOVE THE FILES OVER TO THE LOCATION
# TODO: This is the wrong place to run #load_runconfig ... this should be run from the Msruninfo so that the group, user, taxonomy, etc are filled in accurately.  
        files = [:sldfile, :methodfile, :rawfile, :tunefile, :hplcfile, :graphfile].map {|name| puts "#{name}:  #{@msrun.send(name)}"; [name, @msrun.send(name)]}
        files = files.map do |arr|
	  key = arr.first
	  file = arr.last
	  next if file.nil?
          location = cp_to file, @msrun.archive_location
	  @msrun.send("#{key}=", location)
        end
      end
      # This loads the runconfig settings into the msrun object
      def config
        runconfig = load_runconfig(File.dirname(@msrun.rawfile))
	@msrun.group ||= runconfig[:group]
	@msrun.user ||= runconfig[:user]
	@msrun.rawid ||= File.basename(@msrun.rawfile, ".RAW")
      end
      # This defines the location for the archived directory and can be used by a File.join command to generate a FilePath
      # location = (group, user, mtime, experiment_name)
      # @param None, uses #msrun initialized
      # @return location array
      def define_location
	config
	mtime = File.mtime(@msrun.rawfile)
	arr = [@msrun.group, @msrun.user, "#{mtime.year}#{"%02d" % mtime.mon}#{"%02d" % mtime.day}", @msrun.rawid]
	t = Time.now
	@location = File.join(arr.zip( ["Unknown", "unknown", "#{t.year}#{"%02d" % t.mon}#{"%02d" % t.day}", "Never see this"] ).map {|a| a.first.nil? ? a.last : a.first }  )
        @msrun.archive_location = @location
      end
      # OS independent filename splitter "/path/to/file" =>
      # ['path','to','file']
      def split_filename(fn)
	fn.split(/[\/\\]/)
      end

      # OS independent basename getter
      def basename(fn)
	split_filename(fn).last
      end

      def under_mount?(filename)
	split_filename(File.expand_path(filename))[0,@mount_dir_pieces.size] == @mount_dir_pieces
      end

      # assumes the file is already under the mount
      # returns its path relative to the mount
      def relative_path(filename)
	@mount_dir_pieces ||= @mount_dir.size
	pieces = split_filename(File.expand_path(filename))
	File.join(pieces[@mount_dir_pieces.size..-1])
      end

      # move the file under the mount.  If @tmp_subdir is defined, it will use that directory.
      # returns the expanded path of the file
      def cp_under_mount(filename)
	dest = File.join(@mount_dir, tmp_subdir || "", File.basename(filename))
	FileUtils.cp( filename, dest, preserve=true )
	dest
      end

      def cp_to(filename, mounted_dest) # Always returns the destination as an explicit location relative to the mount directory
	dest = File.join(@mount_dir, mounted_dest )#, File.basename(filename))
	FileUtils.mkdir_p(dest)
	FileUtils.cp( filename, dest, :preserve => true)
	File.join(dest, File.basename(filename))
      end

      def full_path(relative_filename)
	File.join(@mount_dir, relative_filename)
      end
    end # class << self
  end # class ArchiveMount
end # Module
