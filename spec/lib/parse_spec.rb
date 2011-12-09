require 'spec_helper'
require 'xcalibur'
Test_sld = { v2_0: TESTFILE + '/SWG_serum_100511165501.sld', v2_1: TESTFILE + '/_110131184745.sld'}
Test_meth = { v2_0: 'C:\\Xcalibur\\methods\\SWG_serum_sample.meth', v2_1: 'C:\\Xcalibur\\methods\\test1_1_etd.meth'}

describe 'Parses SLD files' do
  it 'parses v2.1 w/postprocessing files' do
    sld_file = Test_sld[:v2_1]
    @sld = Ms::Xcalibur::Sld.new(sld_file)
    @sld.parse
    match = @sld.sldrows.first.methodfile
    @sld.sldrows.first.methodfile.should == Test_meth[:v2_1]
    @sld.sldrows.first.sequence_vial.should == '2A05'
  end
  it 'parses v2.07 files' do
    sld_file = Test_sld[:v2_0]
    @sld = Ms::Xcalibur::Sld.new(sld_file)
    @sld.parse
    @sld.sldrows.first.methodfile.should == Test_meth[:v2_0]
    @sld.sldrows.first.sequence_vial.should == '2B01'
  end
  it 'parses without error these fail cases' do 
    sld_files = Dir.glob(File.join( TESTFILE + '/matt*.sld'))
    @slds = sld_files.map {|f| Ms::Xcalibur::Sld.new(f)}
    @slds.each(&:parse)
    vial_nums = @slds.map do |s| 
      s.sldrows.map {|row| row.sequence_vial }
    end
    vial_nums.should == [["2F01"], ["2F01", "2F02", "2F03", "2F04", "2F05", "2F06"], []]
  end
end

describe 'Parses method files' do
  describe "v2.07" do 
    it 'returns a .LTQTune' do
      methodfile = TESTFILE + '/45min.meth'
      method = Ms::Xcalibur::Method.new(methodfile)
      method.parse
      method.tunefile.should == "C:\\Xcalibur\\methods\\12012010.LTQTune"
    end
    it "does it twice" do 
      methodfile = TESTFILE + '/BSA.meth'
      method = Ms::Xcalibur::Method.new(methodfile)
      method.parse
      method.tunefile.should == "C:\\Xcalibur\\methods\\12012010.LTQTune"
    end
  end # v2.07
  describe "v2.10" do 
    it 'returns a .LTQTune' do
      methodfile = TESTFILE + '/2d_lsingleload.meth'
      method = Ms::Xcalibur::Method.new(methodfile)
      method.parse
      method.tunefile.should == "C:\\Xcalibur\\methods\\07132011_angiotensin.LTQTune"
    end
  end #v2.1
end

if RbConfig::CONFIG['host_os'] === 'win'
  describe 'finds eksigent output files' do
    it 'uses a raw to find an ek2_[/.*/].txt file' do
      testraw = TESTFILE + '/time_test.RAW'
      test = Ms::Eksigent::Ultra2D.new(testraw)
      test.eksfile.should equal 'ek2_test.txt'
      # AH crap... I need a solution across all platforms... ?
      # ...other than the temp one I just implemented...
    end
  end

  describe 'Builds the MsrunInfo thing' do
    before do
      sld_file = Test_sld[:v2_0]
      @sld = Ms::Xcalibur::Sld.new(sld_file).parse
      @sld.sldrows[0].rawfile = TESTFILE + '/time_test.RAW'
      #	@sld.sldrows.first.rawfile.should.equal 'time_test.raw'
      @msrun = Ms::MsrunInfo.new(@sld.sldrows[0])
      @msrun.rawfile.should equal @sld.sldrows.first.rawfile
      @msrun.grab_files
    end
    it 'gets tunefile' do
      if File.exist?(@msrun.methodfile )
        @msrun.tunefile[/(\..*)$/,1].should equal ".LTQTune"
      end
    end
    it 'gets eksfile' do
      if File.exist?(@msrun.methodfile)
        @msrun.hplcfile[/ek2.*(\..*)$/,1].should equal ".txt"
      end
    end
    it 'has same data as @sld' do
      @sld.sldfile.should equal @msrun.sldfile
      @sld.sldrows.first.methodfile.should equal @msrun.methodfile
      @sld.sldrows.first.rawfile.should equal @msrun.rawfile
      @sld.sldrows.first.sequence_vial.should equal @msrun.sequence_vial
    end
    if ENV["OS"] && ENV["OS"][/Windows/] == 'Windows'
      it 'parses the EKS file!!' do
        @msrun.inj_volume.class.should equal (3.0).class
      end
    end
  end
end # If not windows

