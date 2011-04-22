require 'spec_helper'

describe 'database information gathered' do

	it 'contains the information parsed' do 
		input = TESTFILE + '/single_metric.txt'
		@metric = Metric.new(input)
		measures = @metric.slice_hash
		@metric.to_database
		a, b = measures.sort.first, @metric.slice_matches(Msrun.all(:metricsfile => input)).sort.first
		a.name.to_sym.should.equal b.name
		a.raw_id.should.equal b.raw_id
		a.category.should.equal b.category
		a.value.to_f.should.equal b.value
		a.subcat.should.equal b.subcat
	end

	it 'contains only a single set of data for each time run' do 
		input = TESTFILE + '/single_metric.txt'
		@metric = Metric.new(input)
		measures = @metric.slice_hash
		@metric.to_database
		@metric = Metric.new(input)
		@metric.to_database
		measures.length.should.equal @metric.slice_matches(Msrun.all(:metricsfile => input)).length
		measures.sort.slice(0..5).map(&:value).map(&:to_f).should.equal @metric.slice_matches(Msrun.all(:metricsfile => input)).sort.slice(0..5).map(&:value)
	end


end

