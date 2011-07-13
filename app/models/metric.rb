class Metric
  include DataMapper::Resource
  property :id, Serial
  property :metric_input_file, FilePath

  # Associations
  has 1, :chromatography, required: false
  has 1, :ms1, required: false
  has 1, :dynamic_sampling, required: false
  has 1, :ion_source, required: false
  has 1, :ion_treatment, required: false
  has 1, :peptide_ids, required: false
  has 1, :ms2, required: false
  has 1, :run_comparison, required: false

  has 1, :comparison, required: false


  belongs_to :msrun, :required => false      # I think this lacking an id parameter is the reason for the error?
end
