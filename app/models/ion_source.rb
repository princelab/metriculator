class IonSource
  include DataMapper::Resource
  property :id, Serial
  has 1, :spectrum_counts
  has 1, :ion_injection_times_for_ids_ms
  has 1, :top_ion_abundance_measures
  has 1, :number_of_ions_vs_charge
  has 1, :ion_ids_by_charge_state_relative_to_2
  has 1, :average_peptide_lengths_for_different_charge_states
  has 1, :average_peptide_lengths_for_charge_2_for_different_numbers_of_mobile_protons
  has 1, :numbers_of_ion_ids_at_different_charges_with_1_mobile_proton
  has 1, :percent_of_ids_at_different_charges_and_mobile_protons_relative_to_ids_with_1_mobile_proton

  belongs_to :metric

  def hashes
    hash = {}
    hash[:spectrum_counts] = self.spectrum_counts.attributes
    hash[:ion_injection_times_for_ids_ms] = self.ion_injection_times_for_ids_ms.attributes
    hash[:top_ion_abundance_measures] = self.top_ion_abundance_measures.attributes if self.top_ion_abundance_measures.respond_to?(:attributes)
    hash[:number_of_ions_vs_charge] = self.number_of_ions_vs_charge.attributes
    hash[:ion_ids_by_charge_state_relative_to_2] = self.ion_ids_by_charge_state_relative_to_2.attributes
    hash[:average_peptide_lengths_for_different_charge_states] = self.average_peptide_lengths_for_different_charge_states.attributes
    hash[:average_peptide_lengths_for_charge_2_for_different_numbers_of_mobile_protons] = self.average_peptide_lengths_for_charge_2_for_different_numbers_of_mobile_protons.attributes
    hash[:numbers_of_ion_ids_at_different_charges_with_1_mobile_proton] = self.numbers_of_ion_ids_at_different_charges_with_1_mobile_proton.attributes
    hash[:percent_of_ids_at_different_charges_and_mobile_protons_relative_to_ids_with_1_mobile_proton] = self.percent_of_ids_at_different_charges_and_mobile_protons_relative_to_ids_with_1_mobile_proton.attributes
    hash
  end
  def to_yaml
    self.hashes.to_yaml
  end
end

###########################
# Child Models
###########################

class SpectrumCounts
  include DataMapper::Resource
  property :id, Serial
  property :ms2_scans, 				Integer
  property :ms1_scans_full, 	Integer
  property :ms1_scans_other, 	Integer

  belongs_to :ion_source
end

class NumberOfIonsVsCharge
  include DataMapper::Resource
  property :id, Serial
  property :charge_1, 			Float
  property :charge_2, 			Float
  property :charge_3, 			Float
  property :charge_4, 			Float
  property :charge_5, 			Float

  belongs_to :ion_source
end

class IonIdsByChargeStateRelativeTo2
  include DataMapper::Resource
  property :id, Serial
  property :_2_ion_count, 			Float
  property :charge_1, 			Float
  property :charge_2, 			Float
  property :charge_3, 			Float
  property :charge_4, 			Float

  belongs_to :ion_source
end

class AveragePeptideLengthsForDifferentChargeStates
  include DataMapper::Resource
  property :id, Serial
  property :charge_1, 			Float
  property :charge_2, 			Float
  property :charge_3, 			Float
  property :charge_4, 			Float

  belongs_to :ion_source
end

class AveragePeptideLengthsForCharge2ForDifferentNumbersOfMobileProtons
  include DataMapper::Resource
  property :id, Serial
  property :naa_ch_2_mp_1, 			Float
  property :naa_ch_2_mp_0, 			Float
  property :naa_ch_2_mp_1, 			Float
  property :naa_ch_2_mp_2, 			Float

  belongs_to :ion_source
end

class NumbersOfIonIdsAtDifferentChargesWith1MobileProton
  include DataMapper::Resource
  property :id, Serial
  property :ch_1_mp_1, 			Float
  property :ch_2_mp_1, 			Float
  property :ch_3_mp_1, 			Float
  property :ch_4_mp_1, 			Float

  belongs_to :ion_source
end

class PercentOfIdsAtDifferentChargesAndMobileProtonsRelativeToIdsWith1MobileProton
  include DataMapper::Resource
  property :id, Serial
  property :ch_1_mp_1, 			Float
  property :ch_1_mp_0, 			Float
  property :ch_1_mp_1, 			Float
  property :ch_2_mp_1, 			Float
  property :ch_2_mp_0, 			Float
  property :ch_2_mp_1, 			Float
  property :ch_3_mp_1, 			Float
  property :ch_3_mp_0, 			Float
  property :ch_3_mp_1, 			Float

  belongs_to :ion_source
end

class IonInjectionTimesForIdsMs
  include DataMapper::Resource
  property :id, Serial
  property :ms1_median, 			Float
  property :ms1_maximum, 			Float
  property :ms2_median, 			Float
  property :ms2_maximun, 			Float
  property :ms2_fract_max, 			Float

  belongs_to :ion_source
end

class TopIonAbundanceMeasures
  include DataMapper::Resource
  property :id, Serial
  property :top_10_abund, 			Float
  property :top_25_abund, 			Float
  property :top_50_abund, 			Float
  property :fractab_top, 			Float
  property :fractab_top_10, 			Float
  property :fractab_top_100, 			Float

  belongs_to :ion_source
end














