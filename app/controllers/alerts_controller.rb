class AlertsController < ApplicationController

  def destroy
    puts "IN DESTROY METHOD"
    alert = Alert.get(params[:id])
    alert.destroy if alert

    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
end
