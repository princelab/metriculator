class IonTreatment
  include DataMapper::Resource
  property :id, Serial		
  has 1, :precursor_m_z_monoisotope_exact_m_z, required: false

  belongs_to :metric, :key => true
  def hashes
    hash = {}
    hash[:precursor_m_z_monoisotope_exact_m_z] = self.precursor_m_z_monoisotope_exact_m_z.attributes
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

  belongs_to :ion_treatment, :key => true
end



