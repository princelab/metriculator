require 'spec_helper'

describe 'database information gathered' do

	it 'contains the information parsed' do 
		input = TESTFILE + '/single_metric.txt'
		@metric = Ms::NIST::Metric.new(input)
		measures = @metric.slice_hash
		@metric.to_database#(:migrate => true)
		a, b = measures.sort.first, Ms::ComparisonGrapher.slice_matches(Msrun.all(:metricsfile => input)).sort.first
    p a
    p b
		a.name.to_sym.should == b.name
		a.raw_id.should == b.raw_id
		a.category.should == b.category
		a.value.to_f.should == b.value
		a.subcat.should == b.subcat
	end
=begin
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
=end

end

