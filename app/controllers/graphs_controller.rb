class GraphsController < ApplicationController
  def show
    @title = 'hello'
    @entry_dir = Dir.pwd
    @category = 'chromatography'.to_sym
  end
end
