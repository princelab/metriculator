# The rails controller for all alert actions
class AlertsController < ApplicationController
# Show an index of alerts (only alerts which have a 'show' attribute set to true
  def index
    @alerts = Alert.all(show: true).page(params[:page])
  end
# This action permits the hiding of alerts.  It never actually deletes them, it just sets 'show' to false.
  def destroy
    alert = Alert.get(params[:id])
    alert.update(show: false) if alert
    
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
# This action will hide all the visible alerts, rather than just hiding a single alert.
  def remove_all
    puts "IN REMOVE_ALL METHOD"
    Alert.all(show: true).update({ show: false })
    respond_to do |format|
      format.js {render :index }
      format.html {render :index }
    end
  end
end
