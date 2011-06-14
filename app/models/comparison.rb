class Comparison
  include DataMapper::Resource
  property :id, Serial

  property :start_timestamp, DateTime
  property :end_timestamp, DateTime

  property :taxonomy, String

  belongs_to :metric
end
