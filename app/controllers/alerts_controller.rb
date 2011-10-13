class AlertsController < ApplicationController
  def index
    @alerts = Alert.all(show: true)
  end
  def destroy
    puts "IN DESTROY METHOD"
    alert = Alert.get(params[:id])
    alert.update(show: false) if alert
    
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
  def destroy_all
  p @alerts
  p params
    @alerts.each do |alert|
      alert.update(show: false) if alert
      respond_to do |format|
        format.js {render :nothing => true}
      end
    end
  end
end
