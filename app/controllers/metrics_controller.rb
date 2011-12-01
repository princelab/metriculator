# Controller for Metric actions
class MetricsController < ApplicationController

# The show action for a single Metric
  def show
    @metric = Metric.get(params[:id])
  end

# The index action for showing all metrics
  def index
    @metrics = Metric.all.page(params[:page])
  end
end
