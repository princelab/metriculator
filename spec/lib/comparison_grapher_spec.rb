describe 'graphs metrics' do 
	before do 
		@match_old = Msrun.all 
		@match_new = Msrun.all[2]
	end
	it 'generates pdfs' do 
		puts "\n"
		ComparisonGrapher.graph_matches(ComparisonGrapher.slice_matches(@match_new), ComparisonGrapher.slice_matches(@match_old) )
		File.exist?('chromatography/first_and_last_ms1_rt_min_first_ms1.svg').should.equal true
	end
	it 'concatenates them into a giant image' do
		file = 'index.html'
		File.exist?(file).should.equal true
	end
end
