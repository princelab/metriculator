class Metric
  include DataMapper::Resource
	property :metric_input_file, 	FilePath, :key => true
	#property :metric_input_file, 			FilePath
	
# Associations
	has 1, :chromatography
	has 1, :ms1
	has 1, :dynamic_sampling
	has 1, :ion_source
	has 1, :ion_treatment
	has 1, :peptide_ids
	has 1, :ms2
	has 1, :run_comparison

  has 1, :comparison


	belongs_to :msrun, :key => true
end
