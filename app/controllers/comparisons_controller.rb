class ComparisonsController < ApplicationController
  def index
    @comparisons = Comparison.all
  end

  def show
  end

  def create
    #TODO: first check if one exists already, and redirect to it.
    first_set = get_msruns_from_array_of_ids(params[:comparison1])
    second_set = get_msruns_from_array_of_ids(params[:comparison2])

    comp = Comparison.create
    comp.msrun_firsts = first_set
    comp.msrun_seconds = second_set
    comp.save
    comp.graph

    redirect_to :action => "show", :id => comp.id
  end

  private
  def get_msruns_from_array_of_ids(ids)
    ret = ids.map do |id|
      Msrun.get(id)
    end
    ret
  end
end
