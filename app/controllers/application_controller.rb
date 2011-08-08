require 'dm-rails/middleware/identity_map'
class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  before_filter :load_alerts

  def load_alerts
    @alerts = Alerts.all
  end
end
