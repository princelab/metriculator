require 'spec_helper'
describe 'generates metrics' do 
  it 'runs the NIST package to generate metrics' do 
    if `hostname` === 'Hermes'
      Messenger.set_test_location(TESTFILE + '/')
    elsif `hostname` === 'jp1'
      Messenger.set_test_location(AppConfig[:nodes][:server][:archive_root])
    else
      Messenger.set_test_location(Dir.pwd)
    end
    Messenger.add_metric(TESTFILE + '/time_test.raw')
   #TODO this should use a tmp directory to store the results, from which the file can then be moved over to the server subsequently?  Should that be the #metrics_to_database method? 
  end
end
describe 'parses metrics and databases them' do
  before do 
    @msruns = Msrun.all
    @metric = Ms::NIST::Metric.new(TESTFILE + '/test3__1.txt')
    @metric.slice_hash
    @metric.to_database
    @matches = Msrun.all # matches is the result of a Msrun.all OR Msrun.first OR Msrun.get(*args)
    @match = Msrun.first(@metric.slice_hash.first.raw_id)
  end	
  after :each do
    (Msrun.all - @msruns).each(&:destroy)
  end
  it 'has appropriate test values... (find test values)' do 
    @metric.parse.class.should == Hash
  end
  it 'sends the data to the database' do
    @match.class.should == Msrun
  end

  it 'pulls back the metric test from the database' do 
    @match.raw_id.should == @metric.raw_ids.first
  end

end

