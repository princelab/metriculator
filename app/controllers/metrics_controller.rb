# Controller for Metric actions
class MetricsController < ApplicationController

# The show action for a single Metric
  def show
    @metric = Metric.get(params[:id])
    msrun = Msrun.get(params[:id])
    @data = {}
    ApplicationHelper::Categories.each do |cat|
      if cat == 'uplc'
        tmp = {"Max Pressure" => msrun.hplc_max_p, "Mean Pressure" => msrun.hplc_avg_p, "Std Deviation of Mean Pressure" => msrun.hplc_std_p }
        @data[ApplicationController::Name_legend[cat]] = tmp
      else 
        tmp = {}
        @metric.send(cat).hashes.each do |k, v|
          tmp2 = {}
          v.each do |key, val|
            unless key[/id/]
              tmp2[ApplicationController::Name_legend[key.to_s]] = val
            end
          end
          tmp[ApplicationController::Name_legend[k.to_s]] = tmp2 
        end
      end
      @data[ApplicationController::Name_legend[cat]] = tmp
    end
  end

# The index action for showing all metrics
  def index
    @metrics = Metric.all.page(params[:page])
  end
end
