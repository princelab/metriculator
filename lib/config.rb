#
require 'pathname'
require_relative 'merge.rb'
# Default settings for the application
App_defaults = {
  metric_instrument_type: "ORBI",
  admin_email: "admin@example.org",
  comparison_directory: Pathname.new(File.join(File.expand_path(File.dirname(__FILE__)), "..", "public", "comparisons")).cleanpath.to_s,
  hplc_graph_directory: Pathname.new(File.join(File.expand_path(File.dirname(__FILE__)), "..", "public", "hplc_graphs")).cleanpath.to_s,
	nodes: {
		instrument: { system: "Windows", archive_root: "O:\\" },
		metrics: { system: "Windows", archive_root: "O:\\", program_locale: Pathname.new(File.join(File.expand_path(File.dirname(__FILE__)), "..", 'NISTMSQCv1_0_3', 'scripts', 'run_NISTMSQC_pipeline.pl')).cleanpath.to_s },
		server: { system: "Linux", archive_root: "/media/orbitrap" }
	}, 
	quality_control: [
		{ name: "Trypsin BSA digest", filter: "QC_bsa" }, 
			{ name: "HEK_digest", filter: "QC_hek" }	]
}
require 'yaml'
#File.open("archiver_defaults.yml", 'w') {|out| out.print App_defaults.to_yaml }
# These are the config settings for the app, as generated by deeper_merging the defaults with the settings
if File.exist? ("archiver_config.yml")
  AppConfig = App_defaults.deeper_merge(YAML.load_file('archiver_config.yml')) 
else
  AppConfig = App_defaults
end
# This constant contains an array of all the root storage locations
Roots = AppConfig[:nodes].map {|h| h.last[:archive_root]}
# Default settings for the QC automatic processing

Qc_defaults = { 
	:autorun=>true, 
	:alert=>true,
	:alert_email=>"ryanmt@byu.net", 
# This next value is intended to be the number of standard deviations from the norm that is tolerable without alerting
	:default_allowed_variance=>2, 
	:peptide_ids=>{
		:AveragesVsRtForIdedPeptides=>{:charge_q4=>false, :charge_q1=>false, :length_q4=>false, :length_q1=>false}, 
		:PrecursorMZForIds=>{:med_charge_4=>false, :med_charge_3=>false, :med_charge_2=>false, :med_charge_1=>false, :med_q4_rt=>false, :med_q1_rt=>false, :med_q4_tic=>false, :med_q1_tic=>false, :precursor_max=>false, :precursor_min=>false, :quart_ratio=>false, :half_width=>false, :median=>true}, 
		:TotalIonCurrentForIdsAtPeakMaxima=>{:mid_interq_tic=>false, :interq_tic=>false, :med_tic_id_1000=>false}, 
		:PeptideCounts=>{:ions_peptide=>false, :net_oversample=>false, :miss_tryp_abund=>false, :miss_tryp_cnts=>false, :miss_tryp_peps=>false, :semi_tryp_abund=>false, :semi_tryp_cnts=>false, :semi_tryp_peps=>false, :ions=>true, :peptides=>true}, 
		:TrypticPeptideCounts=>{:ions_peptide=>true, :abundance_1000=>false, :abundance_pct=>false, :ions=>true, :peptides=>true}
	}, 
	:ms2=>{
		:Ms2IdAbundReported=>{:_95_5_pctile=>false, :_75_25_pctile=>false, :half_width=>false, :median=>true}, 
		:Ms2IdSpectra=>{:s_n_interq=>false, :s_n_median=>true, :npeaks_interq=>false, :npeaks_median=>false}, 
		:Ms1IdAbundAtMs2Acquisition=>{:_95_5_pctile=>false, :_75_25_pctile=>false, :half_width=>false, :median=>true}, 
		:PrecursorMZPeptideIonMZ2ChargeOnlyReject045MZ=>{:ppm_interq=>false, :ppm_median=>true, :mean_absolute=>false, :median=>true, :spectra=>false}
	}, 
	:ms1=>{
		:Ms1TotalIonCurrentForDifferentRtPeriods=>{:to_end_of_run=>true, :last_id_quart=>true, :middle_id=>true, :_1st_quart_id=>true}, 
		:Ms1IdMax=>{:_95_5_pctile=>false, :_75_25_pctile=>false, :_95_5_midrt=>false, :_75_25_midrt=>false, :median_midrt=>false, :quart_ratio=>false, :half_width=>false, :median=>true}, 
		:Ms1DuringMiddleAndEarlyPeptideRetentionPeriod=>{:ms1_falls_10x=>true, :ms1_jumps_10x=>true, :max_ms1_fall=>true, :max_ms1_jump=>true, :esi_off_early=>false, :esi_off_middle=>false, :s2s_4qrt_med=>false, :s2s_3qrt_med=>false, :s2s_2qrt_med=>false, :s2s_1qrt_med=>false, :s2s_3q_med=>false, :scan_to_scan=>false, :npeaks_median=>false, :tic_median_1000=>true, :s_n_median=>true}
	}, 
	:ion_treatment=>{
		:PrecursorMZMonoisotopeExactMZ=>{:next_half_8=>false, :next_half_7=>false, :next_half_6=>false, :next_half_5=>false, :next_half_4=>false, :next_half_3=>false, :next_half_2=>false, :top_half=>false, :betw_1_6_0_8=>true, :betw_3_1_1_6=>true, :betw_6_3_3_1=>false, :betw_12_5_6_3=>false, :betw_25_0_12_5=>false, :betw_50_0_25_0=>false, :betw_100_0_50_0=>false, :more_than_100=>false}
	}, 
	:ion_source=>{
		:TopIonAbundanceMeasures=>{:fractab_top_100=>false, :fractab_top_10=>false, :fractab_top=>false, :top_50_abund=>true, :top_25_abund=>false, :top_10_abund=>false}, 
		:IonInjectionTimesForIdsMs=>{:ms2_fract_max=>false, :ms2_maximun=>false, :ms2_median=>false, :ms1_maximum=>false, :ms1_median=>true}, 
		:PercentOfIdsAtDifferentChargesAndMobileProtonsRelativeToIdsWith1MobileProton=>{:ch_3_mp_1=>false, :ch_3_mp_0=>false, :ch_2_mp_1=>false, :ch_2_mp_0=>false, :ch_1_mp_1=>false, :ch_1_mp_0=>false}, 
		:NumbersOfIonIdsAtDifferentChargesWith1MobileProton=>{:ch_4_mp_1=>false, :ch_3_mp_1=>false, :ch_2_mp_1=>false, :ch_1_mp_1=>false}, 
		:AveragePeptideLengthsForCharge2ForDifferentNumbersOfMobileProtons=>{:naa_ch_2_mp_2=>false, :naa_ch_2_mp_1=>false, :naa_ch_2_mp_0=>false}, 
		:AveragePeptideLengthsForDifferentChargeStates=>{:charge_4=>false, :charge_3=>false, :charge_2=>false, :charge_1=>false}, 
		:IonIdsByChargeStateRelativeTo2=>{:charge_4=>false, :charge_3=>false, :charge_2=>false, :charge_1=>false, :_2_ion_count=>false}, 
		:NumberOfIonsVsCharge=>{:charge_5=>false, :charge_4=>false, :charge_3=>false, :charge_2=>false, :charge_1=>false}, 
		:SpectrumCounts=>{:ms1_scans_other=>false, :ms1_scans_full=>true, :ms2_scans=>true}
	}, 
	:dynamic_sampling=>{
		:Ms1maxMs1sampledAbundanceRatioIdsInefficientSampling=>{:med_bottom_1_2=>false, :med_top_quart=>false, :med_top_dec=>false, :med_top_100=>false, :_9dec_all_ids=>false, :_3q_all_ids=>false, :median_all_ids=>true}, 
		:SingleSpectrumPeptideIonIdentificationsOversamplingMeasure=>{:_1_vs_1_spec=>false, :_1_vs_1_pepion=>false, :fract_1_ions=>false, :peptide_ions=>true}, 
		:RatiosOfPeptideIonsIdedByDifferentNumbersOfSpectraOversamplingMeasure=>{:twice_thrice=>true, :once_twice=>true}, 
		:PeptideIonIdsBy3SpectraHiVs13SpectraLoExtremeOversampling=>{:spec_cnt_excess=>false, :spec_pep_hi=>false, :ratio_hi_lo=>false, :spec_cnts_hi=>false, :pep_ions_hi=>false}, 
		:EarlyAndLateRtOversamplingSpectrumIdsUniquePeptideIdsChromatographicFlowThroughBleed=>{:last_decile=>false, :first_decile=>false}, 
		:NearbyResamplingOfIdsOversamplingDetails=>{:quart_dm_z=>false, :median_dm_z=>false, :_1dec_rt_diff_s=>false, :_1q_rt_diff_s=>false, :med_rt_diff_s=>false, :repeated_ids=>false}
	}, 
	:chromatography=>{
		:RtMs1maxRtMs2ForIdsSec=>{:third_quart=>false, :first_quart=>false, :median_diff=>false, :med_diff_abs=>false}, 
		:WideRtDifferencesForIds4Min=>{:spectra=>true, :peptides=>true}, 
		:PeakWidthsAtHalfMaxOverRtDecilesForIds=>{:last_decile=>false, :median_value=>false, :first_decile=>false}, 
		:PeakWidthAtHalfHeightForIds=>{:ms1_scan_fwhm=>true, :ms1_interscan_s=>false, :_9dec_value=>false, :_3quart_value=>false, :med_100_disp=>false, :med_16th_disp=>false, :med_quart_disp=>false, :median_disper=>false, :med_top_100=>false, :med_top_16th=>false, :med_top_quart=>false, :median_value=>true}, 
		:MaxPeakWidthForIdsSec=>{:last_decile=>false, :third_quart=>false, :median_value=>false}, 
		:MiddlePeptideRetentionTimePeriodMin=>{:pep_id_rate=>false, :ms1_scans=>false, :ms2_scans=>false, :qratio_time=>false, :mid_time=>false, :start_time=>false, :half_period=>false}
	}, 
	:run_comparison=>{
		:MagnitudeOfRtCorrectionOfIntensitiesOfMatchingPeptidesInOtherRuns=>{:comp_to_last=>false, :comp_to_first=>false}, 
		:UncorrectedAndRtCorrectedRelativeIntensitiesOfMatchingPeptidesInOtherRuns=>{:corr_rel_last=>false, :corr_rel_first=>false, :uncor_rel_last=>false, :uncor_rel_first=>false}, 
		:MedianRatiosOfMs1IntensitiesOfMatchingPeptidesInOtherRuns=>{:comp_to_last_2=>false, :comp_to_first_2=>false, :comp_to_last=>false, :comp_to_first=>false, :median_2_diff=>false, :median_diff=>false}, 
		:DifferencesInElutionRankPercentOfMatchingPeptidesInOtherRuns=>{:comp_to_last=>false, :comp_to_first=>false, :median_diff=>false, :average_diff=>false}, 
		:RelativeUniquenessOfPeptidesInDecileFoundAnywhereInOtherRuns=>{:last_decile=>false, :first_decile=>false}, 
		:RelativeFractionOfPeptidesInRetentionDecileMatchingAPeptideInOtherRuns=>{:comp_to_last=>false, :comp_to_first=>false, :last_decile=>false, :first_decile=>false, :all_deciles=>false}
	}
} 
File.open("qc_defaults.yml", 'w') {|out| out.print Qc_defaults.to_yaml }
# These are the options to be used, as generated by merging option hashes together
QcConfig = Qc_defaults.merge(YAML.load_file("qc_config.yml"))


# These are the default settings for the Runs
  Run_defaults = { :run_metrics => false, :group => 'UNKNOWN' }
# Here we have a function which will load up the runconfig settings for the given directory, iterating through the level of the directory structure
# @param [String] a Directory from which to start
# @return sets @runConfig to contain the values
def load_runconfig(directory)
  restore_dir = Dir.pwd
  Dir.chdir(directory)
  files = []
  last_dir = nil
  while Dir.pwd != last_dir
    glob = Dir.glob('run_config.yml').first
    file = File.absolute_path(glob) if glob
    if file.nil?
      last_dir = Dir.pwd 
      Dir.chdir('..')
      next
    end
    if File.exist?(file)
      files << file
      file = ""
    end
    last_dir = Dir.pwd 
    Dir.chdir('..')
  end
  files.compact
  if files.empty?
    putsv "No runconfig files found:  Running under defaults"
    @runConfig = Run_defaults
  else
    @runConfig = Run_defaults.deeper_merge(YAML.load_file(files.shift))
    files.each {|file| @runConfig = @runConfig.deeper_merge(YAML.load_file(file))}
    puts "RUNDEFAULTS: #{Run_defaults}"
    puts "RUNCONFIG: #{@runConfig}" 
  end
  Dir.chdir restore_dir
  @runConfig
end

# Load the environment?
require_relative 'archiver'
require 'msruninfo'
