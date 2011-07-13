# This is the Struct container to handle the data collected during parsing of MS result files.
MsrunInfoStruct = Struct.new(:sequencefile, :methodfile, :rawfile, :tunefile, :hplcfile, :graphfile, :metricsfile, :sequence_vial, :hplc_vial, :inj_volume, :archive_location, :rawid, :group, :user, :taxonomy) do 

end
require 'yaml'
require 'fileutils'
require 'mount_mapper'
# System Specific Constants
# Location of the NIST directory
Nist_dir = "C:\\NISTMSQC\\scripts"
# Location of the NIST pipeline initiation script
Nist_exe = Nist_dir + "\\run_NISTMSQC_pipeline.pl"

require 'xcalibur'
require 'eksigent'
require 'metrics'
require 'archive_mount'

# This module serves to hold all the MS features into one namespace.  Granted, in the case of proteomics, this is the only namespace in which I care to work.
module Ms
  # This class serves as a container for the information acquired from parsing Xcalibur files and finding Eksigent files which pertain to a MsRun.  This information can then be used directly, or passed into a Database for future reference.
  class MsrunInfo < 
    Struct.new(:sldfile, :methodfile, :rawfile, :tunefile, :hplcfile, :graphfile, :metricsfile, :sequence_vial, :hplc_vial, :inj_volume, :archive_location, :rawid, :group, :user, :taxonomy)  # Every file must have a source hash id that helps us now that things are working.
    attr_accessor :data_struct 
    def initialize(struct = nil)
      if struct
        struct.members.each do |sym|
          self.send("#{sym}="	, struct[sym])
        end
      end
    end
    # This function calls 2 parsers to get the filenames required for the MsRunInfo object.  These are the files that aren't already known from parsing the Sequence file as called from {file:archiver.rb}
    # @param None
    # @return Nothing specific
    def grab_files
      @tunefile = Ms::Xcalibur::Method.new(@methodfile).tunefile
      @hplc_object = Ms::Eksigent::Ultra2D.new(@rawfile)
      @hplcfile = @hplc_object.eksfile
    end
    # This function pulls information from the hplc_file parsing to fill in more details to this MsRunInfo object.
    def fill_in 
      grab_files if @tunefile.nil?
      @inj_volume = @hplc_object.inj_vol
      @hplcfile = @hplc_object.eksfile
      @hplc_vial = @hplc_object.autosampler_vial
    end

    # This method calls the grapher to generate a pressure trace from the data parsed from the recently located hplc file
    def graph_pressure
      @graphfile = @hplc_object.graph
    end
  end # MsrunInfo
end # Ms



def graph_pressure
  @graphfile = @hplc_object.graph
end
  end # MsrunInfo
end # Ms
