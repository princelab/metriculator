require 'app_communication_messaging'

describe 'Messaging' do
  before do 

  end

  it 'returns a list of todo items' do
    Messenger.set_test_location('spec/tfiles')
    reply = Messenger.metrics
    reply.first.chomp.should == "Success"
  end
  it 'writes a message to the file' do 
    Messenger.test_write
    string = File.readlines('tmp.log').first.chomp
    string.should == "Hey, it worked"
  end
end
