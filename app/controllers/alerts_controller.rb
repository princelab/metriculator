class AlertsController < ApplicationController

  def destroy
    alert = Alert.get(params[:id])
    alert.destroy if alert
  end
end
