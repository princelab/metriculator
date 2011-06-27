# Join model for the comparison-msrun many-to-many relationship.
class First
  include DataMapper::Resource
  belongs_to :msrun, :key => true
  belongs_to :comparison, :key => true
end
