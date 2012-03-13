require 'spec_helper'

describe "Archiver-install" do 
  it 'runs in Server mode' do 
    Kernel.stub!(:gets) {1}
    Kernel.should_receive(:puts).with("Setting up for server mode...")
  end
end
