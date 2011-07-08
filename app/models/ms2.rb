class Ms2
  include DataMapper::Resource
  property :id, Serial		
  has 1, :precursor_m_z_peptide_ion_m_z_2_charge_only_reject_0_45_m_z , required: false
  has 1, :ms2_id_spectra, required: false
  has 1, :ms1_id_abund_at_ms2_acquisition, required: false
  has 1, :ms2_id_abund_reported, required: false

  belongs_to :metric, :key => true
  def hashes
    hash = {}
    hash[:precursor_m_z_peptide_ion_m_z_2_charge_only_reject_0_45_m_z] = self.precursor_m_z_peptide_ion_m_z_2_charge_only_reject_0_45_m_z.attributes
    hash[:ms2_id_spectra] = self.ms2_id_spectra.attributes
    hash[:ms1_id_abund_at_ms2_acquisition] = self.ms1_id_abund_at_ms2_acquisition.attributes
    hash[:ms2_id_abund_reported] = self.ms2_id_abund_reported.attributes
    hash
  end
  def to_yaml
    self.hashes.to_yaml
  end
end

###########################
# Child Models
###########################
class PrecursorMZPeptideIonMZ2ChargeOnlyReject045MZ
  include DataMapper::Resource
  property :id, Serial		
  property :spectra, 			Float
  property :median, 			Float
  property :mean_absolute, 			Float
  property :ppm_median, 			Float
  property :ppm_interq, 			Float

  belongs_to :ms2, :key => true
end

class Ms1IdAbundAtMs2Acquisition
  include DataMapper::Resource
  property :id, Serial		
  property :median, 			Float
  property :half_width, 			Float
  property :_75_25_pctile, 			Float
  property :_95_5_pctile, 			Float

  belongs_to :ms2, :key => true
end

class Ms2IdSpectra
  include DataMapper::Resource
  property :id, Serial		
  property :npeaks_median, 			Float
  property :npeaks_interq, 			Float
  property :s_n_median, 			Float
  property :s_n_interq, 			Float
  property :id_score_median, 			Float
  property :id_score_interq, 			Float
  property :idsc_med_q1msmx, 			Float

  belongs_to :ms2, :key => true
end

class Ms2IdAbundReported
  include DataMapper::Resource
  property :id, Serial		
  property :median, 			Float
  property :half_width, 			Float
  property :_75_25_pctile, 			Float
  property :_95_5_pctile, 			Float

  belongs_to :ms2, :key => true
end



