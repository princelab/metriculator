class MetricsController < ApplicationController
  #layout "metric"
  #TODO - why is this here?
  def show
    @metric = Metric.get(params[:id])
  end

  def index
    @metrics = Metric.all.page(params[:page])
  end
end
