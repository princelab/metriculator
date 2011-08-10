require 'spec_helper'

describe 'Ms::ComparisonGrapher' do 
	before :all do 

	end
=begin
	it 'generates images' do 
		puts "\n"
		Ms::ComparisonGrapher.graph_matches(Ms::ComparisonGrapher.slice_matches(@match_new), Ms::ComparisonGrapher.slice_matches(@match_old) )
		File.exist?('chromatography/first_and_last_ms1_rt_min_first_ms1.svg').should == true
	end
	it '' do
		file = 'index.html'
		File.exist?(file).should == true
	end
=end
  it 'calculates the stats as well' do 	
    Alert.all.destroy
    @match_old = Msrun.all 
		@match_new = @match_old.pop
    new = Ms::ComparisonGrapher.slice_matches(@match_new)
    old = Ms::ComparisonGrapher.slice_matches(@match_old)
    reply = Ms::ComparisonGrapher.graph_and_stats(new, old)
    reply.class.should == 'Hash'
  end
end
