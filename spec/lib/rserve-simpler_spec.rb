require 'spec_helper'

describe "Rserve::Simpler" do 
	before :all do 
		@r = Rserve::Simpler.new
		@t = Time.now.to_i.to_s
    @r.converse "setwd('#{Dir.pwd}')"
	end
	it 'plots to X11' do 
		@r.converse "plot(c(1,2,3,4), c(5,6,7,8))"
		sleep 2 
		@r.converse "dev.off()"
	end
	it 'plots to *.png' do 
		@r.converse "png('#{@t}.png')"
		@r.converse "plot(c(1,2,3,4), c(5,6,7,8))"
		@r.converse "dev.off()"
		File.exist?("#{@t}.png").should == true
  end
	it 'plots to *.svg' do 
		@r.converse "svg('#{@t}.svg')"
		@r.converse "plot(c(1,2,3,4), c(5,6,7,8))"
		@r.converse "dev.off()"
		File.exist?("#{@t}.svg").should == true
	end
	it 'plots beanplots' do 
		@r.converse "library('beanplot')"
		@r.converse "beanplot(c(1,2,2,3), c(2,3,4,4,5,6))"
		sleep 2
		@r.converse "dev.off()"
	end
  it 'plots beanplots to png' do 
		@r.converse "library('beanplot')"
		@r.converse "png('#{@t}_beanplot.png')"
		@r.converse "beanplot(c(1,2,2,3), c(2,3,4,4,5,6))"
		@r.converse "dev.off()"
		File.exist?("#{@t}_beanplot.png").should == true
	end
  it 'plots beanplots to svg' do 
		@r.converse "library('beanplot')"
		@r.converse "svg('#{@t}_beanplot.svg')"
		@r.converse "beanplot(c(1,2,2,3), c(2,3,4,4,5,6))"
		@r.converse "dev.off()"
		File.exist?("#{@t}_beanplot.svg").should == true
  end
end


