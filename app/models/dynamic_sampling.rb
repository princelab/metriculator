class DynamicSampling
  include DataMapper::Resource
  property :id, Serial		
  has 1, :nearby_resampling_of_ids_oversampling_details
  has 1, :early_and_late_rt_oversampling_spectrum_ids_unique_peptide_ids_chromatographic_flow_through_bleed
  has 1, :peptide_ion_ids_by_3_spectra_hi_vs_1_3_spectra_lo_extreme_oversampling
  has 1, :ratios_of_peptide_ions_ided_by_different_numbers_of_spectra_oversampling_measure
  has 1, :single_spectrum_peptide_ion_identifications_oversampling_measure
  has 1, :ms1max_ms1sampled_abundance_ratio_ids_inefficient_sampling

  belongs_to :metric

  def hashes
    hash = {}
    hash[:nearby_resampling_of_ids_oversampling_details] = self.nearby_resampling_of_ids_oversampling_details.attributes
    hash[:early_and_late_rt_oversampling_spectrum_ids_unique_peptide_ids_chromatographic_flow_through_bleed] = self.early_and_late_rt_oversampling_spectrum_ids_unique_peptide_ids_chromatographic_flow_through_bleed.attributes
    hash[:peptide_ion_ids_by_3_spectra_hi_vs_1_3_spectra_lo_extreme_oversampling] = self.peptide_ion_ids_by_3_spectra_hi_vs_1_3_spectra_lo_extreme_oversampling.attributes
    hash[:ratios_of_peptide_ions_ided_by_different_numbers_of_spectra_oversampling_measure] = self.ratios_of_peptide_ions_ided_by_different_numbers_of_spectra_oversampling_measure.attributes
    hash[:single_spectrum_peptide_ion_identifications_oversampling_measure] = self.single_spectrum_peptide_ion_identifications_oversampling_measure.attributes
    hash[:ms1max_ms1sampled_abundance_ratio_ids_inefficient_sampling] = self.ms1max_ms1sampled_abundance_ratio_ids_inefficient_sampling.attributes
    hash
  end
  def to_yaml
    self.hashes.to_yaml
  end
end

###########################
# Child Models
###########################

class NearbyResamplingOfIdsOversamplingDetails
  include DataMapper::Resource
  property :id, Serial		
  property :repeated_ids, 			Float
  property :med_rt_diff_s, 			Float
  property :_1q_rt_diff_s, 			Float
  property :_1dec_rt_diff_s, 			Float
  property :median_dm_z, 			Float
  property :quart_dm_z, 			Float

  belongs_to :dynamic_sampling
end


class EarlyAndLateRtOversamplingSpectrumIdsUniquePeptideIdsChromatographicFlowThroughBleed
  include DataMapper::Resource
  property :id, Serial		
  property :first_decile, 			Float
  property :last_decile, 			Float

  belongs_to :dynamic_sampling
end

class PeptideIonIdsBy3SpectraHiVs13SpectraLoExtremeOversampling
  include DataMapper::Resource
  property :id, Serial		
  property :pep_ions_hi, 			Float
  property :ratio_hi_lo, 			Float
  property :spec_cnts_hi, 			Float
  property :ratio_hi_lo, 			Float
  property :spec_pep_hi, 			Float
  property :spec_cnt_excess, 			Float

  belongs_to :dynamic_sampling
end

class RatiosOfPeptideIonsIdedByDifferentNumbersOfSpectraOversamplingMeasure
  include DataMapper::Resource
  property :id, Serial		
  property :once_twice, 			Float
  property :twice_thrice, 			Float

  belongs_to :dynamic_sampling
end

class SingleSpectrumPeptideIonIdentificationsOversamplingMeasure
  include DataMapper::Resource
  property :id, Serial		
  property :peptide_ions, 			Float
  property :fract_1_ions, 			Float
  property :_1_vs_1_pepion, 			Float
  property :_1_vs_1_spec, 			Float

  belongs_to :dynamic_sampling
end

class Ms1maxMs1sampledAbundanceRatioIdsInefficientSampling
  include DataMapper::Resource
  property :id, Serial		
  property :median_all_ids, 			Float
  property :_3q_all_ids, 			Float
  property :_9dec_all_ids, 			Float
  property :med_top_100, 			Float
  property :med_top_dec, 			Float
  property :med_top_quart, 			Float
  property :med_bottom_1_2, 			Float

  belongs_to :dynamic_sampling
end





