class Chromatography
	include DataMapper::Resource
	property :id, Serial

	has 1, :first_and_last_ms1_rt_min, required: false
	has 1, :middle_peptide_retention_time_period_min, required: false
	has 1, :max_peak_width_for_ids_sec, required: false
	has 1, :peak_width_at_half_height_for_ids, required: false
	has 1, :peak_widths_at_half_max_over_rt_deciles_for_ids, required: false
	has 1, :wide_rt_differences_for_ids_4_min, required: false
	##### has 1, :fraction_of_repeat_peptide_ids_with_divergent_rt_rt_vs_rt_best_id_chromatographic_bleed
	has 1, :rt_ms1max_rt_ms2_for_ids_sec, required: false

	belongs_to :metric, :key => true

	def hashes
		hash = {}
		hash[:first_and_last_ms1_rt_min] = first_and_last_ms1_rt_min.attributes
		hash[:middle_peptide_retention_time_period_min] = self.middle_peptide_retention_time_period_min.attributes
		hash[:max_peak_width_for_ids_sec] = self.max_peak_width_for_ids_sec.attributes
		hash[:peak_width_at_half_height_for_ids] = self.peak_width_at_half_height_for_ids.attributes
hash[:peak_widths_at_half_max_over_rt_deciles_for_ids] = self.peak_widths_at_half_max_over_rt_deciles_for_ids.attributes
hash[:wide_rt_differences_for_ids_4_min] = self.wide_rt_differences_for_ids_4_min.attributes
hash[:rt_ms1max_rt_ms2_for_ids_sec] = self.rt_ms1max_rt_ms2_for_ids_sec.attributes
		hash
	end
	def to_yaml
		self.hashes.to_yaml
	end
end

###########################
# Child Models
###########################

class FirstAndLastMs1RtMin
	include DataMapper::Resource
		property :id, Serial		
	property :first_ms1, 			Float
	property :last_ms1, 			Float

	belongs_to :chromatography, :key => true
end

class MiddlePeptideRetentionTimePeriodMin
	include DataMapper::Resource
	property :id, Serial		
	property :half_period, 			Float
	property :start_time, 			Float
	property :mid_time, 			Float
	property :qratio_time, 			Float
	property :ms2_scans, 			Float
	property :ms1_scans, 			Float
	property :pep_id_rate, 			Float
	property :id_rate, 			Float
	property :id_efficiency, 			Float

	belongs_to :chromatography, :key => true
end

class MaxPeakWidthForIdsSec
	include DataMapper::Resource
	property :id, Serial		
	property :median_value, 			Float
	property :third_quart, 			Float
	property :last_decile, 			Float

	belongs_to :chromatography, :key => true
end

class PeakWidthAtHalfHeightForIds
	include DataMapper::Resource
	property :id, Serial		
	property :median_value, 			Float
	property :med_top_quart, 			Float
	property :med_top_16th, 			Float
	property :med_top_100, 			Float
	property :median_disper, 			Float
	property :med_quart_disp, 			Float
	property :med_16th_disp, 			Float
	property :med_100_disp, 			Float
	property :_3quart_value, 			Float
	property :_9dec_value, 			Float
	property :ms1_interscan_s, 			Float
	property :ms1_scan_fwhm, 			Float
	property :ids_used, 			Float

	belongs_to :chromatography, :key => true
end

class PeakWidthsAtHalfMaxOverRtDecilesForIds
	include DataMapper::Resource
	property :id, Serial		
	property :first_decile, 			Float
	property :median_value, 			Float
	property :last_decile, 			Float

	belongs_to :chromatography, :key => true
end

class WideRtDifferencesForIds4Min
	include DataMapper::Resource
	property :id, Serial		
	property :peptides, 			Float
	property :spectra, 			Float

	belongs_to :chromatography, :key => true
end

class RtMs1maxRtMs2ForIdsSec
	include DataMapper::Resource
	property :id, Serial		
	property :med_diff_abs, 			Float
	property :median_diff, 			Float
	property :first_quart, 			Float
	property :third_quart, 			Float

	belongs_to :chromatography, :key => true
end





