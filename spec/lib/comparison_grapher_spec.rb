require 'spec_helper'

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
		File.exist?("#{comparison_id}/chromatography/first_and_last_ms1_rt_min/first_ms1.svg").should == true
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

