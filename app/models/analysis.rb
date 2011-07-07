class Analysis
  include DataMapper::Resource
  property :id, Serial
  belongs_to :msrun
end
