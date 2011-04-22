require 'spec_helper'

describe 'merges hashes down as far as hashes go' do
	before do 
	@lower_config = {"group"=>"JTP", "username"=>"ryanmt", "useremail"=>"ryanmt@byu.net", "comments"=>nil, "taxonomy"=>"", "metrics"=>true, "archive_root_dir"=>"ryanmt", "search"=>{"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=> nil}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>nil}, "enzyme"=>"Trypsin", "spectrum"=>{"parent_mass_type"=>"monoisotopic", "parent_mass_error"=>"-10,+10 ppm", "fragment_mass_type"=>"monoisotopic", "fragment_mass_error"=>"-0.4,+0.4 daltons"}}, "quantitation"=>{"spectral_counts"=>true}, "convert"=>{"overwrite"=>true}}
	@upper_config = {"group"=>"ERR", "username"=>"wrong", "useremail"=>"ryanmt@byu.net", "comments"=>"Success!!!", "taxonomy"=>"human", "metrics"=>true, "archive_root_dir"=>"ryanmt", "search"=>{"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=>true}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00719","MOD:01060"]}, "organism" => nil,  "enzyme"=>"Trypsin", "spectrum"=>{"parent_mass_type"=>"monoisotopic", "parent_mass_error"=>"-20,+20 ppm", "fragment_mass_type"=>"monoisotopic", "fragment_mass_error"=>"-0.4,+0.4 daltons"}}, "quantitation"=>{"spectral_counts"=>true}, "convert"=>{"overwrite"=>false}}

	end
	it 'merges first level hash keys / values' do 
		result = @lower_config.deep_merge(@upper_config)
		result.class.should.equal Hash.new.class
		result.sort.should.equal [["archive_root_dir", "ryanmt"], ["comments", "Success!!!"], ["convert", {"overwrite"=>true}], ["group", "JTP"], ["metrics", true], ["quantitation", {"spectral_counts"=>true}], ["search", {"mascot"=>{"run"=>true}, "omssa"=>{"run"=>true}, "tide"=>{"run"=>true}, "xtandem"=>{"run"=>true}, "modifications"=>{"static"=>["MOD:01060"], "variable"=>["MOD:00719", "MOD:01060"]}, "enzyme"=>"Trypsin", "spectrum"=>{"parent_mass_type"=>"monoisotopic", "parent_mass_error"=>"-10,+10 ppm", "fragment_mass_type"=>"monoisotopic", "fragment_mass_error"=>"-0.4,+0.4 daltons"}, "organism"=>nil}], ["taxonomy", "human"], ["useremail", "ryanmt@byu.net"], ["username", "ryanmt"]]
	end
=begin
	it 'merges second level hash keys/values' do 

	end
	it 'replaces array values with array values' do 

	end
=end

end

