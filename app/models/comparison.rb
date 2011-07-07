class Comparison
  include DataMapper::Resource
  property :id, Serial

  property :start_timestamp, DateTime
  property :end_timestamp, DateTime

  property :taxonomy, String

  has n, :firsts#, :child_key => [:msrun_id]
  has n, :msrun_firsts, 'Msrun', :through => :firsts, :via => :msrun# :child_key => [ :msrun_id ]

  has n, :seconds#, :child_key => [:msrun_id]
  has n, :msrun_seconds, 'Msrun', :through => :seconds, :via => :msrun# :child_key => [ :msrun_id ]
end
