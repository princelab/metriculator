require 'spec_helper'

if RUBY_PLATFORM.downcase.include?("darwin")
  TESTFILE = "~/Dropbox/prince_lab_stuff/rails-metrics-site"
end
describe 'Matches to graph trace file from rawfile time' do
  before :each do
    @tmp = Ms::Eksigent::Ultra2D.new
    @tmp.rawfile = TESTFILE + '/time_test.RAW'
  end

  it 'finds rawtime' do
    @tmp.find_match
    @tmp.rawtime.should.equal File.mtime(@tmp.rawfile)
  end
  it 'finds ek2_*.txt file' do
    #@tmp.hplcfile.should.equal @tmp.eksfile
    File.extname(@tmp.eksfile).should == '.txt'
    @tmp.eksfile[/^.*\/ek2_.*\.txt/].should.equal @tmp.eksfile
  end
  it 'parses the ek2_*.txt file correctly' do
    @tmp.eksfile = TESTFILE + '/ek2_test.txt'
    File.extname(@tmp.graph).should == ".svg"
  end
end

describe 'graphs eksigent output' do
  before do
    @tmp = Ms::Eksigent::Ultra2D.new
    @tmp.rawfile = TESTFILE + '/time_test.RAW'
    @tmp.eksfile = TESTFILE + '/ek2_test.txt'
  end
  it 'generates a .svg with the appropriate name' do
    file = @tmp.graph
    @tmp.graphfile.should == file
  end
end
