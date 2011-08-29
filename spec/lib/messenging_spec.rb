require 'spec_helper'
require 'app_communication_messaging'

describe 'Messaging' do
  before do 
    Messenger.set_test_location('spec/tfiles')
  end

  it 'writes a message to the file' do 
    Messenger.test_write
    string = File.readlines('spec/tfiles/tmp.log').first.chomp
    string.should == "Hey, it worked"
  end
  it 'reads a todo list' do 
    Messenger.setup
    reply = Messenger.read_todo
    reply.class.should == Array
    reply.first.chomp.should == 'Success'
  end
end
