class IonTreatment
  include DataMapper::Resource
  property :id, Serial
  has 1, :precursor_m_z_monoisotope_exact_m_z
  has 1, :m_z_medians_for_clusters_at_rt_quartiles_all_charges
  has 1, :fract_of_cluster_abundance_at_50_and_90_of_all_abundance

  belongs_to :metric
  def hashes
    hash = {}
    hash[:precursor_m_z_monoisotope_exact_m_z] = self.precursor_m_z_monoisotope_exact_m_z.attributes
    hash[:m_z_medians_for_clusters_at_rt_quartiles_all_charges] = self.m_z_medians_for_clusters_at_rt_quartiles_all_charges.attributes if self.m_z_medians_for_clusters_at_rt_quartiles_all_charges.respond_to?(:attributes)
    hash[:fract_of_cluster_abundance_at_50_and_90_of_all_abundance] = self.fract_of_cluster_abundance_at_50_and_90_of_all_abundance if self.fract_of_cluster_abundance_at_50_and_90_of_all_abundance.respond_to?(:attributes)
    hash
  end
  def to_yaml
    self.hashes.to_yaml
  end
end


###########################
# Child Models
###########################

class PrecursorMZMonoisotopeExactMZ
  include DataMapper::Resource
  property :id, Serial		
  property :more_than_100, 			Float
  property :betw_100_0_50_0, 			Float
  property :betw_50_0_25_0, 			Float
  property :betw_25_0_12_5, 			Float
  property :betw_12_5_6_3, 			Float
  property :betw_6_3_3_1, 			Float
  property :betw_3_1_1_6, 			Float
  property :betw_1_6_0_8, 			Float
  property :top_half, 			Float
  property :next_half_2, 			Float
  property :next_half_3, 			Float
  property :next_half_4, 			Float
  property :next_half_5, 			Float
  property :next_half_6, 			Float
  property :next_half_7, 			Float
  property :next_half_8, 			Float

  belongs_to :ion_treatment
end

class MZMediansForClustersAtRtQuartilesAllCharges
  include DataMapper::Resource
  property :id, Serial
  property :first_quart,	    Float
  property :second_quart,	    Float
  property :third_quart,	    Float
  property :fourth_quart,	    Float

  belongs_to :ion_treatment
end

class FractOfClusterAbundanceAt50And90OfAllAbundance
  include DataMapper::Resource
  property :id, Serial

  property :_50_ions , Float
  property :_50_id, Float
  property :_50_noidsamp , Float
  property :_50_noidnosamp , Float
  property :_90_ions , Float
  property :_90_id, Float
  property :_90_noidsamp , Float
  property :_90_noidnosamp , Float

  belongs_to :ion_treatment
end
