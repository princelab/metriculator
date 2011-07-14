class PeptideIds
  include DataMapper::Resource
  property :id, Serial		
  has 1, :tryptic_peptide_counts
  has 1, :peptide_counts
  has 1, :total_ion_current_for_ids_at_peak_maxima
  has 1, :precursor_m_z_for_ids
  has 1, :averages_vs_rt_for_ided_peptides

  belongs_to :metric, :key => true
  def hashes
    hash = {}
    hash[:tryptic_peptide_counts] = self.tryptic_peptide_counts.attributes
    hash[:peptide_counts] = self.peptide_counts.attributes
    hash[:total_ion_current_for_ids_at_peak_maxima] = self.total_ion_current_for_ids_at_peak_maxima.attributes
    hash[:precursor_m_z_for_ids] = self.precursor_m_z_for_ids.attributes
    hash[:averages_vs_rt_for_ided_peptides] = self.averages_vs_rt_for_ided_peptides.attributes
    hash
  end
  def to_yaml
    self.hashes.to_yaml
  end
end

###########################
# Child Models
###########################

class TrypticPeptideCounts
  include DataMapper::Resource
  property :id, Serial		
  property :peptides, 			Float
  property :ions, 			Float
  property :identifications, 			Float
  property :abundance_pct, 			Float
  property :abundance_1000, 			Float
  property :ions_peptide, 			Float
  property :ids_peptide, 			Float

  belongs_to :peptide_ids	, :key => true
end

class PeptideCounts
  include DataMapper::Resource
  property :id, Serial		
  property :peptides, 			Float
  property :ions, 			Float
  property :identifications, 			Float
  property :semi_tryp_peps, 			Float
  property :semi_tryp_cnts, 			Float
  property :semi_tryp_abund, 			Float
  property :miss_tryp_peps, 			Float
  property :miss_tryp_cnts, 			Float
  property :miss_tryp_abund, 			Float
  property :net_oversample, 			Float
  property :ions_peptide, 			Float
  property :ids_peptide, 			Float

  belongs_to :peptide_ids, :key => true
end

class TotalIonCurrentForIdsAtPeakMaxima
  include DataMapper::Resource
  property :id, Serial		
  property :med_tic_id_1000, 			Float
  property :interq_tic, 			Float
  property :mid_interq_tic, 			Float

  belongs_to :peptide_ids, :key => true
end

class PrecursorMZForIds
  include DataMapper::Resource
  property :id, Serial		
  property :median, 			Float
  property :half_width, 			Float
  property :quart_ratio, 			Float
  property :precursor_min, 			Float
  property :precursor_max, 			Float
  property :med_q1_tic, 			Float
  property :med_q4_tic, 			Float
  property :med_q1_rt, 			Float
  property :med_q4_rt, 			Float
  property :med_charge_1, 			Float
  property :med_charge_2, 			Float
  property :med_charge_3, 			Float
  property :med_charge_4, 			Float

  belongs_to :peptide_ids, :key => true
end

class AveragesVsRtForIdedPeptides
  include DataMapper::Resource
  property :id, Serial		
  property :length_q1, 			Float
  property :length_q4, 			Float
  property :charge_q1, 			Float
  property :charge_q4, 			Float

  belongs_to :peptide_ids, :key => true
end



