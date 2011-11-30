require 'spec_helper'

describe 'MsrunInfo Object behaves' do 
  before do 
    file = TESTFILE + '/SWG_serum_100511165501.sld'
    @sld = Ms::Xcalibur::Sld.new(file).parse
    @sld.sldrows[0].rawfile = TESTFILE + '/time_test.RAW'
    @msrun = Ms::MsrunInfo.new(@sld.sldrows[0])
    @msrun.tunefile = TESTFILE + '/example_tune.LTQTune'
    @msrun.hplc_object = Ms::Eksigent::Ultra2D.new
    @msrun.hplc_object.rawfile = TESTFILE + "/time_test.RAW"
    @msrun.hplc_object.eksfile = TESTFILE + "/ek2_test.txt"
    @msrun.hplc_object.parse
    @msrun.hplc_object.graph
    @msrun.hplcfile = TESTFILE + "/ek2_test.txt"
    @msrun.fill_in
    @yaml = @msrun.to_yaml
  end
  it 'parses things correctly' do 
    @msrun.hplc_maxP.should == 7209.0
  end
  it "grabs files" do 
    @msrun.hplc_maxP.should_not == 7209.0
    @msrun.grab_files
    @msrun.hplc_maxP.should == 7209.0
  end
end

describe 'Archiver writes to network location' do 
  it 'copied files' do 
    pending "test copy"
  end

  it 'updated locations' do 
    pending 'implement updating and testing of updating locations'
  end

end
