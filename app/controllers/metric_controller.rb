class MetricController < ApplicationController
  def show
    @metric = Metric.all(:msrun_id => params[:id]).first
  end
  
  def index
    @metrics = Metric.all
  end
end
