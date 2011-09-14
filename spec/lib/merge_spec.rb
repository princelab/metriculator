#require 'spec_helper'
require 'merge'
require 'rspec'
describe 'Deep_merge fxn ' do
	before :each do 
    @level1 = {'group' => "JTP", 'username' => 'ryanmt'}
    @level1_fail = { 'group' => 'ERR', 'username' => 'failure', 'taxonomy' => 'should exist' }
    @level1_match = { 'group' => 'JTP', 'username' => 'ryanmt', 'taxonomy' => 'should exist' }
    @level2 = {'group' => ['RIGHT'], 'search' => { 'mascot' => {'run' => true } } }
    @level2_fail = {'group' => ['FAIL'], 'search' => { 'mascot' => {'run' => false}, 'omssa'=> {'run' => true}  }  }
    @level2_match = {'group' => ['RIGHT'], "search" => { 'mascot' => { 'run' => true }, 'omssa' => {'run' => true } } }
    @total = {"group"=>"JTP", "username"=>"ryanmt", "useremail"=>"ryanmt@byu.net", "taxonomy"=>"human", "metrics"=>true, "archive_root_dir"=>"ryanmt", "search"=>{"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=> true}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>nil}, "enzyme"=>"Trypsin", "spectrum"=>{"parent_mass_type"=>"monoisotopic", "fragment_mass_type"=>"monoisotopic", "fragment_mass_error"=>"-0.4,+0.4 daltons"}, "convert"=>{"overwrite"=>true}} }
    @total_fail = {"group"=>"ERR", "username"=>"wrong", "useremail"=>"ryanmt@byu.net", "comments"=>"Success!!!", "taxonomy"=>"", "metrics"=>true, "archive_root_dir"=>"ryanmt", "search"=>{"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=>nil}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00819","MOD:01060"]}, "organism" => nil,  "enzyme"=>"Trypsin", "quantitation"=>{"spectral_counts"=>true}, "convert"=>{"overwrite"=>false}} }
    @total_match = {"group"=>"JTP", "username"=>"ryanmt", "useremail"=>"ryanmt@byu.net", "taxonomy"=>"human", "metrics"=>true, "archive_root_dir"=>"ryanmt", "search"=>{"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=>true}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00819", "MOD:01060"]}, "enzyme"=>"Trypsin", "spectrum"=>{"parent_mass_type"=>"monoisotopic", "fragment_mass_type"=>"monoisotopic", "fragment_mass_error"=>"-0.4,+0.4 daltons"}, "organism"=>nil, "quantitation"=>{"spectral_counts"=>true}, "convert"=>{"overwrite"=>true}}, "comments"=>"Success!!!"}
    @array =  { "modifications"=>{"static"=>["MOD:02060"], "variable"=>["MOD:00719", "MOD:01060"]}   }
    @array_fail = { "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00719"]}  }
    @array_match = { "modifications"=>{"static"=>["MOD:02060"], "variable"=>["MOD:00719", "MOD:01060"]}  }
    @array_with_nil =  { "modifications"=>{"static"=>["MOD:02060"], "variable"=>nil}   }
    @array_with_nil_fail = { "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00719"]}  }
    @array_with_nil_match = { "modifications"=>{"static"=>["MOD:02060"], "variable"=>["MOD:00719"]}  }
	end
  it 'returns a Hash object' do 
		result = @level1_fail.deep_merge(@level1)
    result.class.should == Hash.new.class
  end
  it 'merges an empty string with a full string' do 
    result = {string: ""}.deep_merge({string: "yes"})
    result.should == {string: "yes"}
  end
	it 'merges first level hash keys / values' do 
		result = @level1_fail.deep_merge(@level1)
		result.sort.should == @level1_match.sort
  end
	it 'merges second level hash keys/values' do 
    result = @level2_fail.deep_merge(@level2)
	  result.sort.should == @level2_match.sort
  end
  it 'replaces array values with array values' do
    result = @array_fail.deep_merge(@array)
    result.sort.should == @array_match.sort
  end
  it 'replaces nil values with array values' do
    result = @array_with_nil_fail.deep_merge(@array_with_nil)
    result.sort.should == @array_with_nil_match.sort
  end
  it 'merges a complex thing that represents a likely usage case for this purpose' do 
    result = @total_fail.deep_merge(@total)
    result.should == @total_match
  end
end

