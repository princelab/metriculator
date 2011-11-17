class AlertsController < ApplicationController
  def index
    @alerts = Alert.all(show: true).page(params[:page])
  end
  def destroy
    alert = Alert.get(params[:id])
    alert.update(show: false) if alert
    
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
  def remove_all
    puts "IN REMOVE_ALL METHOD"
    Alert.all(show: true).update({ show: false })
    respond_to do |format|
      format.js {render :index }
      format.html {render :index }
    end
  end
end
