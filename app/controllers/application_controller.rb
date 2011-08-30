require 'dm-rails/middleware/identity_map'
class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  before_filter :load_alerts

  def load_alerts
   # @alerts = Alert.all
    @alerts = Alert.all(:show => true)
  end

  def render_404
    @title = "404 Page Not Found"
    render :template => "public/404.html.haml", :layout => false, :status => 404
  end
end
