require 'spec_helper'

describe "Rserve::Simpler" do 
	before :all do 
		@r = Rserve::Simpler.new
	end
	it 'plots to X11' do 
		@r.converse "plot(c(1,2,3,4), c(5,6,7,8))"
		@r.pause 
		@r.converse "dev.off"
	end
	it 'plots to *.png' do 
		t = Time.now.to_i.to_s
		@r.converse "png('#{t}.png')"
		@r.converse "plot(c(1,2,3,4), c(5,6,7,8)"
		@r.converse "dev.off()"
		File.exist?("#{t}.png").should be(true)
	it 'plots to *.svg' do 
		t = Time.now.to_i.to_s
		@r.converse "svg('#{t}.svg')"
		@r.converse "plot(c(1,2,3,4), c(5,6,7,8)"
		@r.converse "dev.off()"
		File.exist?("#{t}.svg".should be(true)
	end
	it 'plots beanplots' do 
		@r.converse "library('beanplot')"
		@r.converse "beanplot(c(1,2,2,3), c(2,3,4,4,5,6))"
		@r.pause
	end
end



comparison_id = Time.now.to_i
describe 'Ms::ComparisonGrapher' do 
puts "RAILS_ENV: #{::Rails.env}"
@match_old = Msrun.all
@match_new = @match_old.pop(5)
	before :all do 
    @match_old = Msrun.all
    @match_new = @match_old.pop(5)
	end
	it 'generates images' do 
		puts "\n"
		Ms::ComparisonGrapher.graph_matches(Ms::ComparisonGrapher.slice_matches(@match_new), Ms::ComparisonGrapher.slice_matches(@match_old), comparison_id.to_s  )
		File.exist?("public/comparisons/#{comparison_id}/chromatography/first_and_last_ms1_rt_min/first_ms1.svg").should == true
	end
	it 'has a website' do
		file = 'index.html'
		#File.exist?(file).should == true
	end
  it 'calculates the stats as well' do 	
    new = Ms::ComparisonGrapher.slice_matches(@match_new)
    old = Ms::ComparisonGrapher.slice_matches(@match_old)
    reply = Ms::ComparisonGrapher.graph_and_stats(new, old, comparison_id.to_s)
    reply.class.should == Hash
  end
end
