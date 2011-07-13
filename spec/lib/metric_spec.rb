require 'spec_helper'
=begin
describe 'generates metrics' do 

  it 'runs the NIST package to generate metrics over SSH' do 

  end

  it 'returns a "next" signal from the metrics generation process by SSH' do 

  end

end
describe 'parses metrics and databases them' do
  before do 
    @metric = Metric.new( TESTFILE + '/test3__1.txt')
    @metric.slice_hash
    @metric.to_database
    @matches = Msrun.all # matches is the result of a Msrun.all OR Msrun.first OR Msrun.get(*args)
  end	
  it 'has appropriate test values... (find test values)' do 
    @metric.parse.class.should.equal Hash
  end

  it 'sends the data to the database' do
    measure = @metric.slice_hash.first
    raw_id = measure.raw_id
    @match = Msrun.first( raw_id)
    @match.class.should.equal Msrun
  end

  it 'pulls back the metric test from the database' do 
    @match.raw_id.should.equal @metric.raw_ids.first
  end

end
describe 'generates a lot of metrics' do 
  before do
    @files = Dir.entries(TESTFILE + '/metrics/')
    @files = @files.map {|file| File.join(TESTFILE, 'metrics', file) if file[/\.txt/] }.compact
    #@files = [TESTFILE + '/metrics' + '/test1.txt', TESTFILE + '/metrics' + '/nanospray_full.txt']
    #@files = [TESTFILE + '/metrics' + '/test1.txt']
    @metrics = []
  end

  it 'handles all the metrics' do
    @files.each do |file|
      a  = Metric.new(file)
      a.slice_hash
      a.to_database
      @metrics << a
    end
# NOT TRUE!!!  Since each file can contribute many metrics to the mix
  #	@files.length.should.equal Msrun.all.length	
# WHAT CAN I use as a new test?
  end
end
=end
#=begin
describe 'graphs metrics' do 
	before do 
		@metric = Metric.new( TESTFILE + '/test3__1.txt')
#		@measures = @metric.slice_hash
#		saved = @metric.to_database
		@match_old = Msrun.all 
		@match_new = Msrun.all[2]
	end
	it 'generates pdfs' do 
		puts "\n"
		@metric.graph_matches(@metric.slice_matches(@match_new), @metric.slice_matches(@match_old) )
		File.exist?('chromatography/first_and_last_ms1_rt_min_first_ms1.svg').should.equal true
	end
	it 'concatenates them into a giant image' do
		file = 'index.html'
		File.exist?(file).should.equal true
	end

describe '#archiver' do
  let(:metric) { Metric.new(File.join(File.dirname(__FILE__), '..', 'tfiles', 'test3__1.txt')) }
  it 'should populate the database with msrun data from the metrics file' do
    metric.archive
  end
end

# describe 'graphs metrics' do
#   before do
#     # let(:metric) { FactoryGirl.create(:metric) }
#     @metric = Metric.new( TESTFILE + '/test3__1.txt')
#     #		@measures = @metric.slice_hash
#     #		saved = @metric.to_database
#     @match_old = Msrun.all
#     @match_new = Msrun.all[2]
#   end
#   it 'generates pdfs' do
#     puts "\n"
#     @metric.graph_matches(@match_new, @match_old)
#     File.exist?('chromatography/first_and_last_ms1_rt_min_first_ms1.svg').should.equal true
#   end
#   it 'concatenates them into a giant image' do
#     file = 'index.html'
#     File.exist?(file).should.equal true
#   end
# end

#=end
