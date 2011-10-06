require 'spec_helper'

describe 'DBing' do
  describe "Metric" do
    before :all do 
      @input = TESTFILE + '/single_metric.txt'
      @metric = Ms::NIST::Metric.new(@input)
      @measures = @metric.slice_hash
      @metric.to_database
    end
    it 'contains the information parsed' do 
      a, b = @measures.sort.first, Ms::ComparisonGrapher.slice_matches(Msrun.all(:metricsfile => @input)).sort.first
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
      @metric = Metric.new(@input)
      @metric.to_database
      @measures.length.should.equal @metric.slice_matches(Msrun.all(:metricsfile => @input)).length
      @measures.sort.slice(0..5).map(&:value).map(&:to_f).should.equal @metric.slice_matches(Msrun.all(:metricsfile => @input)).sort.slice(0..5).map(&:value)
    end
=end
  end # Metric
  describe "Msrun" do 
    before :each do 
      @msruninfo = YAML.load_file(TESTFILE + '/msruninfo.yml')
      @msruninfo.hplc_object = Ms::Eksigent::Ultra2D.new
      @msruninfo.hplc_object.parse( TESTFILE + '/ek2_test.txt')
      @msruninfo.hplc_object.rawfile = @msruninfo.rawfile
      @msruninfo.hplc_object.graphfile = TESTFILE + '/ek2_test.svg'
      @response = @msruninfo.to_database
    end
    it 'feeds into the database' do 
      @response.class.should == Fixnum
    end
    it 'contains the same information' do 
      @db = Msrun.first(:id => @response)
      @db.hplc_maxP.should == @msruninfo.hplc_maxP
    end
  end
end # DBing

