require 'merge'

describe 'Deep_merge fxn ' do
	before :each do 
    @level1 = {'group' => "JTP", 'username' => 'ryanmt'}
    @level1_fail = { 'group' => 'ERR', 'username' => 'failure', 'taxonomy' => 'should exist' }
    @level1_match = { 'group' => 'JTP', 'username' => 'ryanmt', 'taxonomy' => 'should exist' }
    @level2 = {'group' => 'RIGHT', 'search' => { 'mascot' => {'run' => true } } }
    @level2_fail = {'group' => 'FAIL', 'search' => { 'mascot' => {'run' => false}, 'omssa'=> {'run' => true}  }  }
    @level2_match = {'group' => 'RIGHT', "search" => { 'mascot' => { 'run' => true }, 'omssa' => {'run' => true } } }
    @total = {"group"=>"JTP", "username"=>"ryanmt", "useremail"=>"ryanmt@byu.net", "taxonomy"=>"", "metrics"=>true, "archive_root_dir"=>"ryanmt", "search"=>{"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=> nil}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>nil}, "enzyme"=>"Trypsin", "spectrum"=>{"parent_mass_type"=>"monoisotopic", "fragment_mass_type"=>"monoisotopic", "fragment_mass_error"=>"-0.4,+0.4 daltons"}, "convert"=>{"overwrite"=>true}} }
    @total_fail = {"group"=>"ERR", "username"=>"wrong", "useremail"=>"ryanmt@byu.net", "comments"=>"Success!!!", "taxonomy"=>"human", "metrics"=>true, "archive_root_dir"=>"ryanmt", "search"=>{"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=>true}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00819","MOD:01060"]}, "organism" => nil,  "enzyme"=>"Trypsin", "quantitation"=>{"spectral_counts"=>true}, "convert"=>{"overwrite"=>false}} }
    @total_match = {"group"=>"JTP", "username"=>"ryanmt", "useremail"=>"ryanmt@byu.net", "taxonomy"=>"human", "metrics"=>true, "archive_root_dir"=>"ryanmt", "search"=>{"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=>true}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00819", "MOD:01060"]}, "enzyme"=>"Trypsin", "spectrum"=>{"parent_mass_type"=>"monoisotopic", "fragment_mass_type"=>"monoisotopic", "fragment_mass_error"=>"-0.4,+0.4 daltons"}, "organism"=>nil, "quantitation"=>{"spectral_counts"=>true}, "convert"=>{"overwrite"=>true}}, "comments"=>"Success!!!"}
    @array =  { "modifications"=>{"static"=>["MOD:02060"], "variable"=>["MOD:00719"]}   }
    @array_fail = { "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00719", "MOD:01060"]}  }
    @array_match = { "modifications"=>{"static"=>["MOD:02060"], "variable"=>["MOD:00719", "MOD:01060"]}  }
	end
  it 'returns a Hash object' do 
		result = @level1.deep_merge(@level1_fail)
    result.class.should == Hash.new.class
  end
	it 'merges first level hash keys / values' do 
		result = @level1.deep_merge(@level1_fail)
		result.should == @level1_match
  end
	it 'merges second level hash keys/values' do 
    result = @level2.deep_merge(@level2_fail)
	  result.should == @level2_match
  end
  it 'merges a complex thing that represents a likely usage case for this purpose' do 
    result = @total.deep_merge(@total_fail)
    result.should == @total_match
  end
	it 'replaces array values with array values' do
    result = @array.deep_merge(@array_fail)
    result.should == @array_match
  end
end

=begin

[["archive_root_dir", "ryanmt"], ["comments", "Success!!!"], ["convert", {"overwrite"=>true}], ["group", "JTP"], ["metrics", true], ["quantitation", {"spectral_counts"=>true}], ["search", {"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=>true}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00719", "MOD:01060"]}, "enzyme"=>"Trypsin", "spectrum"=>{"parent_mass_type"=>"monoisotopic", "parent_mass_error"=>"-10,+10 ppm", "fragment_mass_type"=>"monoisotopic", "fragment_mass_error"=>"-0.4,+0.4 daltons"}, "organism"=>nil}], ["taxonomy", "human"], ["useremail", "ryanmt@byu.net"], ["username", "ryanmt"]]
                                [["archive_root_dir", "ryanmt"], ["comments", "Success!!!"], ["convert", {"overwrite"=>true}], ["group", "JTP"], ["metrics", true], ["quantitation", {"spectral_counts"=>true}], ["search", {"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=>true}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00719", "MOD:01060"]}, "enzyme"=>"Trypsin", "spectrum"=>{"parent_mass_type"=>"monoisotopic", "parent_mass_error"=>"-10,+10 ppm", "fragment_mass_type"=>"monoisotopic", "fragment_mass_error"=>"-0.4,+0.4 daltons"}, "organism"=>nil}], ["taxonomy", "human"], ["useremail", "ryanmt@byu.net"], ["username", "ryanmt"]]

=end
