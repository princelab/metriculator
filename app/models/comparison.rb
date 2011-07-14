class Comparison
  include DataMapper::Resource
  property :id, Serial

  property :start_timestamp, DateTime
  property :end_timestamp, DateTime

  property :taxonomy, String

  has n, :firsts
  has n, :msrun_firsts, 'Msrun', :through => :firsts, :via => :msrun

  has n, :seconds
  has n, :msrun_seconds, 'Msrun', :through => :seconds, :via => :msrun
end
