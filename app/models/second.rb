# Join model for the comparison-msrun many-to-many relationship.
class Second
  include DataMapper::Resource

  belongs_to :msrun, :key => true
  belongs_to :comparison, :key => true
end
