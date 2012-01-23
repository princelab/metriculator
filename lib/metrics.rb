#!/usr/bin/ruby

require 'msruninfo'

#To make sure Time.random() is available. This really should go somewhere else.
require 'meta_programming'
require 'yaml'

# A fancy struct which is used to contain each measurement and streamline the internal handling of the metric data
# It contains two methods necessary for the handling the comparison and output of this data.
class ::Measurement <
  # Structure, the entire basis for this class
  Struct.new(:name, :raw_id, :time, :value, :category, :subcat) do
    # Standard comparison operator defined for sorting by time
    def <=>(other)
      self[:name] <=> other[:name]
    #  self[:time] <=> other[:time]
    end

    # Defined the output format to make the printout more concise.
    def to_s
      "struct Measurement name=#{self.name}, raw_id=#{self.raw_id}, time=#{self.time}, value=#{self.value}, category=#{self.category}, subcat=#{self.subcat}"
    end
  end
end
# This is the set of default settings for the {Ms::NIST::Metric#to_database} method
DatabaseDefaults = {migrate: false, upgrade: false}
module Ms
# NIST, for the organization that wrote the METRIC producing programs we are using.
  class NIST
    class Metric		# Metric parsing fxns
      attr_accessor :out_hash, :metricsfile, :rawfile, :raw_ids
      # Not really a metric fxn, but rather a generic camelcase formatter
      # @param [String] String to convert to camelcase from snakecase
      # @return [String] converted to camelcase string
      def camelcase(str)
        str.split('_').map{|word| word.capitalize}.join('')
      end

      # Not really a metric fxn either, but converts from Camelcase or separated words into a snakecase, enforcing separation of numbers and ensuring that it doesn't end in an underscore or contain multiple underscores in series
      # @param [String] String to convert
      # @return [String] converted String
      def snakecase(str)
        str.gsub(/(\s|\W)/, '_').gsub(/(_+)/, '_').gsub(/(_$)/, "").gsub(/^(\d)/, '_\1').downcase
      end
# Takes a new Metric file.
      def initialize(file = nil)
        @metricsfile = file
      end

      # Eventually, this should be the function that calls the appropriate cascade of features to run the metrics
      # @param [File] This is the optional file you can input.  Otherwise, it will look for the local instance variable rawfile to run metrics on that file.
      def run_metrics(rawfile = nil)
        if rawfile
          @rawfile = rawfile
        end
        @rawtime = File.mtime(@rawfile)
        ArchiveMount.metric_config
        #Working on some major changes to the mount thing... that lets me have it do the work for me!!
        # to ensure it only runs the one file... it needs to be alone in a directory... 
        if Dir.glob(File.join(File.absolute_path(@rawfile).sub(File.basename(@rawfile), ''), "*#{File.extname(@rawfile)}")).size > 1
          tmp_id = Time.now.to_i
          path = File.dirname(ArchiveMount.cp_to(@rawfile, tmp_id.to_s))
        else
          path = File.dirname(@rawfile)
          puts "PATH: #{path}"
          puts @rawfile
        end
        output_metrics_file = File.join(path, (File.basename(@rawfile, '.raw') + '.txt'))
        putsv "PATH: #{path}"
        putsv "output_metrics_file: #{output_metrics_file}"
        #putsv "#{ArchiveMount.config.metric_instrument_type}"
        instrument_type = "ORBI"
        default_lib = 'human'
        cmd_line = %Q{#{::NistProgram} --in_dir "#{path}" --out_file "#{output_metrics_file}" --library #{default_lib}  --instrument_type #{instrument_type} }
        response = %x[#{cmd_line}]
        p response
        ## PARSE THE FILE
        m = Ms::NIST::Metric.new(output_metrics_file)
        m.archive
        ## CLEAN THE DIRECTORIES (tmp if used, and metrics regardless)
      end

      # Archive the metric data by ensuring it is parsed {#parse} and sending it to the database {#to_database}
      def archive
        parse if @out_hash.nil?
        to_database
      end

      # Parse the given instance variable metricsfile to get the metrics data into Hashes, if you want to get {Measurement}, you can use the {#slice_hash} fxn
      # @param None, but it references the @metricsfile
      # @return [Hash] the out_hash which contains the parsed data
      def parse				# Returns the out_hash
        output = {}
        array = IO.readlines(@metricsfile, 'r:us-ascii').first.split("\r\n")
        outs_hash = {}; key = ""
        measures = []
        array.each_index do |index|
          @reading = true if array[index][/^(Begin).*eries.*/,1] == "Begin"
          if @reading
            if array[index] == ""
            elsif array[index-1] == ""
              #puts "key: #{key} and array[index] = #{array[index]}"
              key = snakecase(array[index])
              #puts "key: #{key}"
              @num_files = key[/files_analyzed_(\d*)/,1].to_i if key[/(files_analyzed_).*/,1] == "files_analyzed_"
            elsif outs_hash[key]
              #puts "elsif put key: #{key} and array[index] = #{array[index]}"
              outs_hash[key] << array[index].split("\t")
            else
              #puts "else put key: #{key} and array[index] = #{array[index]}"
              outs_hash[key] = []
              outs_hash[key] << array[index].split("\t")
            end
          end
        end
        @metrics_input_files = outs_hash["files_analyzed_#{@num_files}"].map{|arr| arr.last}.compact
        @raw_ids = @metrics_input_files.map{|file| File.basename(file,".RAW.MGF.TSV") }
        @out_hash = {}
        outs_hash.each_pair do |key, values|
          @out_hash[key] = {}
          values.each do |value|
            if value[0]
              property = snakecase(value.shift)
              next if value.nil?
              @out_hash[key][property] = value
              #	puts "out_hash[key][property] == #{@out_hash[key][property]}"
              #				puts "key: #{key} and property: #{property}"
            end
          end
        end
        File.open("tmp_key.yml", 'w') {|f| f.write output.to_yaml }
        ["files_analyzed_#{@num_files}", 'begin_runseries_results', 'begin_series_1', "run_number_#{(1..@num_files).to_a.join('_')}", 'end_series_1', 'fraction_of_repeat_peptide_ids_with_divergent_rt_rt_vs_rt_best_id_chromatographic_bleed'].each {|item| @out_hash.delete(item)}
        @out_hash
      end

      # This will take the @out_hash and return that data as an Array of {Measurement} structs
      # @param None, but will use out_hash or call parse if that doesn't exist to try to get the data
      # @return [Array] an array of {Measurement} structs which are also referenced as @measures
      def slice_hash
        parse if @out_hash.nil?
        @measures = []; @data = {}; item = 0
        @metrics_input_files.each do |file|
          @out_hash.each_pair do |subcategory, value_hash|
            value_hash.each_pair do |property, value|
              @measures << Measurement.new( property.to_sym, File.basename(file,".RAW.MGF.TSV"), @rawtime || Time.random(2), value[item], @@ref_hash[subcategory.to_sym].to_sym, subcategory.to_sym)
            end
          end
          item +=1
        end
        @measures		
      end

      # This fxn takes a hash of options which are merged with default databasing settings and sends the metric to the database. 
      # @param [Hash] options with are used to define the databasing process
      # @return Nothing, since it is pushing things to the configured database
      def to_database(opts={})
        database_opts = DatabaseDefaults.merge(opts)
        if database_opts[:migrate]
          require 'dm-migrations'
          DataMapper.auto_migrate!  # This one wipes things!
          puts "DataMapper#auto_migrate-ing"
        elsif database_opts[:upgrade]
          require 'dm-migrations'
          DataMapper.auto_upgrade!
          puts "DataMapper#auto_upgrade-ing"
        end
        objects = []; item = 0
        slice_hash if @measures.nil?
        @metrics_input_files.each do |file|
          tmp = Msrun.first_or_create({raw_id: "#{File.basename(file,".RAW.MGF.TSV")}",  metricsfile: @metricsfile})
          tmp.metric = ::Metric.first_or_create( {msrun_id: tmp.id}, {metric_input_file: @metricsfile} ) # The second hash is what is used if you are creating, while the first hash is the parameters you find by
          @@categories.map {|category|  tmp.metric.send("#{category}=".to_sym, Kernel.const_get(camelcase(category)).first_or_new({id: tmp.id})) }
          @out_hash.each_pair do |key, value_hash|
            outs = tmp.metric.send((@@ref_hash[key.to_sym]).to_sym).send("#{key.downcase}=".to_sym, Kernel.const_get(camelcase(key)).first_or_create({id: tmp.id}))#, value_hash ))
            value_hash.each_pair do |property, array|
              tmp.metric.send((@@ref_hash[key.to_sym]).to_sym).send("#{key.downcase}".to_sym).send("#{property}=".to_sym, array[item])
            end
            begin
              tmp.metric.send((@@ref_hash[key.to_sym]).to_sym).send("#{key.downcase}".to_sym).save
            rescue DataObjects::SyntaxError
              puts "DATAOBJECTS ERROR\n--------------------------=================================---------------------------"
            end
          end
          item +=1
          objects << tmp
        end
        worked = objects.map{|obj| obj.save!}
        puts "\n----------------\nSave failed\n----------------" if worked.uniq.include?(false)
        return worked.uniq.include?(false) ? false : true
        # false if worked.uniq.include?(false)
      end 	# to_database

      # CLASS variables that I don't ever want to have to see!!!!
      @@ref_hash = {
        spectrum_counts: "ion_source", 	first_and_last_ms1_rt_min: "chromatography", 	middle_peptide_retention_time_period_min: "chromatography", max_peak_width_for_ids_sec: "chromatography", peak_width_at_half_height_for_ids: "chromatography", peak_widths_at_half_max_over_rt_deciles_for_ids: "chromatography", wide_rt_differences_for_ids_4_min: "chromatography", 	
        rt_ms1max_rt_ms2_for_ids_sec: "chromatography",	ms1_during_middle_and_early_peptide_retention_period: "ms1", 	ms1_total_ion_current_for_different_rt_periods: "ms1", ms1_id_max: "ms1", 	nearby_resampling_of_ids_oversampling_details: "dynamic_sampling", 	early_and_late_rt_oversampling_spectrum_ids_unique_peptide_ids_chromatographic_flow_through_bleed: "dynamic_sampling", peptide_ion_ids_by_3_spectra_hi_vs_1_3_spectra_lo_extreme_oversampling: "dynamic_sampling",
        ratios_of_peptide_ions_ided_by_different_numbers_of_spectra_oversampling_measure: "dynamic_sampling", single_spectrum_peptide_ion_identifications_oversampling_measure: "dynamic_sampling", ms1max_ms1sampled_abundance_ratio_ids_inefficient_sampling: "dynamic_sampling", ion_injection_times_for_ids_ms: "ion_source", top_ion_abundance_measures: "ion_source", number_of_ions_vs_charge: "ion_source",
        ion_ids_by_charge_state_relative_to_2: "ion_source",	average_peptide_lengths_for_different_charge_states: "ion_source", average_peptide_lengths_for_charge_2_for_different_numbers_of_mobile_protons: "ion_source", numbers_of_ion_ids_at_different_charges_with_1_mobile_proton: "ion_source", percent_of_ids_at_different_charges_and_mobile_protons_relative_to_ids_with_1_mobile_proton: "ion_source", precursor_m_z_monoisotope_exact_m_z: "ion_treatment",
        tryptic_peptide_counts: "peptide_ids",	peptide_counts: "peptide_ids",	total_ion_current_for_ids_at_peak_maxima: "peptide_ids",	precursor_m_z_for_ids: "peptide_ids",	averages_vs_rt_for_ided_peptides: "peptide_ids",	precursor_m_z_peptide_ion_m_z_2_charge_only_reject_0_45_m_z: "ms2",	ms2_id_spectra: "ms2",	ms1_id_abund_at_ms2_acquisition: "ms2",	ms2_id_abund_reported: "ms2",	
        relative_fraction_of_peptides_in_retention_decile_matching_a_peptide_in_other_runs: "run_comparison", 	relative_uniqueness_of_peptides_in_decile_found_anywhere_in_other_runs: "run_comparison", differences_in_elution_rank_percent_of_matching_peptides_in_other_runs: "run_comparison", median_ratios_of_ms1_intensities_of_matching_peptides_in_other_runs: "run_comparison",
        uncorrected_and_rt_corrected_relative_intensities_of_matching_peptides_in_other_runs: "run_comparison", magnitude_of_rt_correction_of_intensities_of_matching_peptides_in_other_runs: "run_comparison"
      }

      @@categories = ["chromatography", "ms1", "dynamic_sampling", "ion_source", "ion_treatment", "peptide_ids", "ms2", "run_comparison"]
    end # Metric parsing fxns
  end # NIST
end # module Ms
