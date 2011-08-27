#This class provides the utility for organizing the file structure and handling the archive as a Mounted location, simplifying the use elsewhere in the library
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
      @msrun.archive_location = @location
    end
  end
end
# Location of cygwin's bin
CygBin = "C:\\cygwin\\bin"
# Location of cygwin's home directory
CygHome = "C:\\cygwin\\home\\LTQ2"
# The destination SSH location
UserHost = 'ryanmt@jp1'
# Location of the program on the {#UserHost}
ProgramLocale = '/home/ryanmt/Dropbox/coding/ms/archiver/lib/archiver.rb'
# This is currently the way we are passing the objects around.  In this case, this functions on a windows machine which has cygwin ssh utilities installed to the default directory to pass objects to the specified location
# @param [Object] the object you wish to pass to the other computer (In this case, a MsRunInfo that is yamled out to file, and then passed to #archiver.rb with a --linux tag
# return [String] A string representing the command delivered at the UserHost computer location
def send_msruninfo_to_linux_via_ssh(object)
  File.open('tmp.yml', 'w') {|out| YAML.dump(object, out)}
  file_move = %Q[#{CygBin}\\scp tmp.yml #{UserHost}:/tmp/]
  kick = %Q[#{CygBin}\\ssh #{UserHost} -C '#{ProgramLocale} --linux /tmp/tmp.yml ']
  %x[#{kick}]
  kick
end
