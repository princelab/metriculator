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
  def remove_all
    puts "IN REMOVE_ALL METHOD"
    Alert.update_all({ show: false }, { show: true })
    respond_to do |format|
      format.js {render :nothing => true}
    end
  end
end
