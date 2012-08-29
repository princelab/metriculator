require 'spec_helper'

comparison_id = TESTFILE + '/' + Time.now.to_i.to_s
describe 'Ms::ComparisonGrapher' do 
#puts "RAILS_ENV: #{::Rails.env}"
	before :all do 
    @match_old = Msrun.all
    @match_new_short = @match_old.pop
    @match_new = @match_old.pop(5)
    puts "@match_old.size: #{@match_old.size}"
    puts "@match_new.size: #{@match_new.size}"
	end
	it 'generates images for many new matches' do 
		puts "\n"
		Ms::ComparisonGrapher.graph_matches(Ms::ComparisonGrapher.slice_matches(@match_new), Ms::ComparisonGrapher.slice_matches(@match_old), comparison_id.to_s  )
		File.exist?("#{comparison_id}/chromatography/first_and_last_ms1_rt_min/first_ms1.svg").should == true
	end
	it 'generates images for just one new match' do 
		Ms::ComparisonGrapher.graph_matches(Ms::ComparisonGrapher.slice_matches(@match_new_short), Ms::ComparisonGrapher.slice_matches(@match_old), "#{comparison_id.to_s}_short"  )
		File.exist?("#{comparison_id}_short/chromatography/first_and_last_ms1_rt_min/first_ms1.svg").should == true
  end
	it 'has a website' do
		file = 'index.html'
		#File.exist?(file).should == true
	end
  it 'calculates the stats as well' do 	
    new = Ms::ComparisonGrapher.slice_matches(@match_new)
    old = Ms::ComparisonGrapher.slice_matches(@match_old)
    reply = Ms::ComparisonGrapher.graph_and_stats(new, old, "#{comparison_id.to_s}_stats")
    reply.class.should == Hash
  end
end

