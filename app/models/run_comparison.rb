class RunComparison
  include DataMapper::Resource
  property :id, Serial
  has 1, :relative_fraction_of_peptides_in_retention_decile_matching_a_peptide_in_other_runs
  has 1, :relative_uniqueness_of_peptides_in_decile_found_anywhere_in_other_runs
  has 1, :differences_in_elution_rank_percent_of_matching_peptides_in_other_runs
  has 1, :median_ratios_of_ms1_intensities_of_matching_peptides_in_other_runs
  has 1, :uncorrected_and_rt_corrected_relative_intensities_of_matching_peptides_in_other_runs
  has 1, :magnitude_of_rt_correction_of_intensities_of_matching_peptides_in_other_runs

  belongs_to :metric
  def hashes
    hash = {}
    hash[:relative_fraction_of_peptides_in_retention_decile_matching_a_peptide_in_other_runs] = self.relative_fraction_of_peptides_in_retention_decile_matching_a_peptide_in_other_runs.attributes if self.relative_fraction_of_peptides_in_retention_decile_matching_a_peptide_in_other_runs.respond_to?(:attributes)
    hash[:relative_uniqueness_of_peptides_in_decile_found_anywhere_in_other_runs] = self.relative_uniqueness_of_peptides_in_decile_found_anywhere_in_other_runs.attributes if self.relative_uniqueness_of_peptides_in_decile_found_anywhere_in_other_runs.respond_to?(:attributes)
    hash[:differences_in_elution_rank_percent_of_matching_peptides_in_other_runs] = self.differences_in_elution_rank_percent_of_matching_peptides_in_other_runs.attributes if self.differences_in_elution_rank_percent_of_matching_peptides_in_other_runs.respond_to?(:attributes)
    hash[:median_ratios_of_ms1_intensities_of_matching_peptides_in_other_runs] = self.median_ratios_of_ms1_intensities_of_matching_peptides_in_other_runs.attributes if self.median_ratios_of_ms1_intensities_of_matching_peptides_in_other_runs.respond_to?(:attributes)
    hash[:uncorrected_and_rt_corrected_relative_intensities_of_matching_peptides_in_other_runs] = self.uncorrected_and_rt_corrected_relative_intensities_of_matching_peptides_in_other_runs.attributes if self.uncorrected_and_rt_corrected_relative_intensities_of_matching_peptides_in_other_runs.respond_to?(:attributes)
    hash[:magnitude_of_rt_correction_of_intensities_of_matching_peptides_in_other_runs] = self.magnitude_of_rt_correction_of_intensities_of_matching_peptides_in_other_runs.attributes if self.magnitude_of_rt_correction_of_intensities_of_matching_peptides_in_other_runs.respond_to?(:attributes)
    hash
  end

  def to_yaml
    self.hashes.to_yaml
  end
end

###########################
# Child Models
###########################

class RelativeFractionOfPeptidesInRetentionDecileMatchingAPeptideInOtherRuns
  include DataMapper::Resource
  property :id, Serial
  property :all_deciles, 			Float
  property :first_decile, 			Float
  property :last_decile, 			Float
  property :comp_to_first, 			Float
  property :comp_to_last, 			Float

  belongs_to :run_comparison
end

class RelativeUniquenessOfPeptidesInDecileFoundAnywhereInOtherRuns
  include DataMapper::Resource
  property :id, Serial		
  property :first_decile, 			Float
  property :last_decile, 			Float

  belongs_to :run_comparison
end

class DifferencesInElutionRankPercentOfMatchingPeptidesInOtherRuns
  include DataMapper::Resource
  property :id, Serial		
  property :average_diff, 			Float
  property :median_diff, 			Float
  property :comp_to_first, 			Float
  property :comp_to_last, 			Float

  belongs_to :run_comparison
end

class MedianRatiosOfMs1IntensitiesOfMatchingPeptidesInOtherRuns
  include DataMapper::Resource
  property :id, Serial		
  property :median_diff, 			Float
  property :median_2_diff, 			Float
  property :comp_to_first, 			Float
  property :comp_to_last, 			Float
  property :comp_to_first_2, 			Float
  property :comp_to_last_2, 			Float

  belongs_to :run_comparison
end

class UncorrectedAndRtCorrectedRelativeIntensitiesOfMatchingPeptidesInOtherRuns
  include DataMapper::Resource
  property :id, Serial		
  property :uncor_rel_first, 			Float
  property :uncor_rel_last, 			Float
  property :corr_rel_first, 			Float
  property :corr_rel_last, 			Float

  belongs_to :run_comparison
end

class MagnitudeOfRtCorrectionOfIntensitiesOfMatchingPeptidesInOtherRuns
  include DataMapper::Resource
  property :id, Serial		
  property :comp_to_first, 			Float
  property :comp_to_last, 			Float

  belongs_to :run_comparison
end

