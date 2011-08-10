class Alert
  include DataMapper::Resource
  property :id, Serial

  property :created_at, DateTime
  property :email, Boolean, :default => true
  property :show, Boolean, :default => true
  property :description, String, :length => 1..255

end
