# This is the Struct container to handle the data collected during parsing of MS result files.
MsrunInfoStruct = Struct.new(:sequencefile, :methodfile, :rawfile, :tunefile, :hplcfile, :graphfile, :metricsfile, :sequence_vial, :hplc_vial, :inj_volume, :archive_location, :rawid, :group, :user, :taxonomy) do 

end
require 'yaml'
require 'fileutils'
# System Specific Constants
# Location of the NIST directory
Nist_dir = "C:\\NISTMSQC\\scripts"
# Location of the NIST pipeline initiation script
Nist_exe = Nist_dir + "\\run_NISTMSQC_pipeline.pl"

require 'xcalibur'
require 'eksigent'
require 'metrics'
require 'archive_mount'
require 'comparison_grapher'

# This module serves to hold all the MS features into one namespace.  Granted, in the case of proteomics, this is the only namespace in which I care to work.
module Ms
  # This class serves as a container for the information acquired from parsing Xcalibur files and finding Eksigent files which pertain to a MsRun.  This information can then be used directly, or passed into a Database for future reference.
  class MsrunInfo  
    [:sldfile, :methodfile, :rawfile, :tunefile, :hplcfile, :graphfile, :metricsfile, :sequence_vial, :hplc_vial, :inj_volume, :archive_location, :rawid, :group, :user, :taxonomy, :hplc_maxP, :hplc_avgP, :hplc_stdP].each {|item| attr_accessor item }  # Every file must have a source hash id that helps us know that things are working.
    attr_accessor :data_struct, :msrun_id, :hplc_object
    def initialize(struct = nil)
      if struct
        membs = struct.members
        membs.delete(:parsed)
        membs.compact.each do |sym|
          self.send("#{sym}="	, struct[sym])
        end
        load_runconfig(File.dirname(@rawfile))
      end
#TODO add a way to support the runconfig loading as part of metriculator
    end
# This fxn sets archive conditions for when you only want to archive the rawfile information itself, prior to metric generation
# @param Filename The rawfile you wish to add to the database
# @return Integer The id number for the Msrun object just created
    def raw_only_archive(rawfile)
      self.rawfile = rawfile
      self.rawid = File.basename(rawfile, '.raw')
      [:sldfile, :methodfile, :tunefile, :hplcfile, :graphfile, :metricsfile, :sequence_vial, :hplc_vial, :inj_volume, :hplc_maxP, :hplc_avgP, :hplc_stdP].each { |sym| self.send("#{sym}=".to_sym, nil)}
      begin 
	@db = ::Msrun.first_or_create(:raw_id => rawid, :rawfile => rawfile )
      rescue 
	binding.pry
      end
      @db.id
    end
    # This function calls 2 parsers to get the filenames required for the MsRunInfo object.  These are the files that aren't already known from parsing the Sequence file as called from {file:archiver.rb}
    # @param None
    # @return Nothing specific
    def grab_files
      self.tunefile = Ms::Xcalibur::Method.new(methodfile).parse
      putsv "Tunefile: #{tunefile}"
      @hplc_object = Ms::Eksigent::Ultra2D.new(rawfile)
      self.hplcfile = @hplc_object.eksfile
      @hplc_object.parse
    end
    # This function pulls information from the hplc_file parsing to fill in more details to this MsRunInfo object.
    def fill_in 
      grab_files if tunefile.nil?
      self.inj_volume = @hplc_object.inj_vol
      self.hplc_vial = @hplc_object.autosampler_vial
      self.hplc_maxP = @hplc_object.maxpressure
      self.hplc_avgP = @hplc_object.meanpressure
      self.hplc_avgP = @hplc_object.meanpressure
      self.hplc_stdP = @hplc_object.pressure_stdev
      self.rawid = File.basename(rawfile, ".raw")
    end

    # This method calls the grapher to generate a pressure trace from the data parsed from the recently located hplc file
    def graph_pressure
      graphfile = @hplc_object.graph
    end
# This function checks that everything is prepped and sends the data to the database.
# @return Integer The id number for the Msrun object just created
    def to_database
      fill_in if hplc_maxP.nil?
      graph_pressure if @graphfile.nil?
      @db = Msrun.first_or_create(:raw_id => rawid, :group => group, :rawfile => rawfile, :methodfile => methodfile, :tunefile => tunefile, :hplcfile => hplcfile, :graphfile => graphfile, :archive_location => archive_location, :taxonomy => taxonomy, :inj_volume => inj_volume, :autosampler_vial => hplc_vial, :hplc_max_p => hplc_maxP, :hplc_std_p => hplc_stdP, :hplc_avg_p => hplc_avgP)
      @db.id
    end
  end # MsrunInfo
end # Ms
