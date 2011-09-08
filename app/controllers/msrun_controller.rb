class MsrunController < ApplicationController
  def show
  end
  def index
    @msruns = Msrun.all 
  end
end
