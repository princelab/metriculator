class MetricsController < ApplicationController
  #layout "metric"
  #TODO - why is this here?
  def show
    @metric = Metric.all(:msrun_id => params[:id]).first
  end

  def index
    @metrics = Metric.all
  end
end
