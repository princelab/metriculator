class Ms1
  include DataMapper::Resource
  property :id, Serial
  has 1, :ms1_during_middle_and_early_peptide_retention_period
  has 1, :ms1_total_ion_current_for_different_rt_periods
  has 1, :ms1_id_max

  belongs_to :metric
  def hashes
    hash = {}
    hash[:ms1_during_middle_and_early_peptide_retention_period] = self.ms1_during_middle_and_early_peptide_retention_period.attributes
    hash[:ms1_total_ion_current_for_different_rt_periods] = self.ms1_total_ion_current_for_different_rt_periods.attributes
    hash[:ms1_id_max] = self.ms1_id_max.attributes
    hash
  end

  def to_yaml
    self.hashes.to_yaml
  end
end


###########################
# Child Models
###########################

class Ms1DuringMiddleAndEarlyPeptideRetentionPeriod
  include DataMapper::Resource
  property :id, Serial
  property :s_n_median, 			Float
  property :tic_median_1000, 			Float
  property :npeaks_median, 			Float
  property :scan_to_scan, 			Float
  property :s2s_3q_med, 			Float
  property :s2s_1qrt_med, 			Float
  property :s2s_2qrt_med, 			Float
  property :s2s_3qrt_med, 			Float
  property :s2s_4qrt_med, 			Float
  property :esi_off_middle, 			Float
  property :esi_off_early, 			Float
  property :max_ms1_jump, 			Float
  property :max_ms1_fall, 			Float
  property :ms1_jumps_10x, 			Float
  property :ms1_falls_10x, 			Float

  belongs_to :ms1
end

class Ms1TotalIonCurrentForDifferentRtPeriods
  include DataMapper::Resource
  property :id, Serial
  property :_1st_quart_id, 			Float
  property :middle_id, 			Float
  property :last_id_quart, 			Float
  property :to_end_of_run, 			Float

  belongs_to :ms1
end

class Ms1IdMax
  include DataMapper::Resource
  property :id, Serial
  property :median, 			Float
  property :half_width, 			Float
  property :quart_ratio, 			Float
  property :median_midrt, 			Float
  property :_75_25_midrt, 			Float
  property :_95_5_midrt, 			Float
  property :_75_25_pctile, 			Float
  property :_95_5_pctile, 			Float

  belongs_to :ms1
end

class Ms1TotalIonCurrentForDifferentRtPeriods
  include DataMapper::Resource
  property :id, Serial
  property :_1st_quart_id, 			Float
  property :middle_id, 			Float
  property :last_id_quart, 			Float
  property :to_end_of_run, 			Float

  belongs_to :ms1
end
