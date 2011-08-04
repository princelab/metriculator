require 'app_communication_messaging'

describe 'Messaging' do
  before do 

  end

  it 'returns a list of todo items' do
    
  end
  it 'writes a message to the file' do 
    Messenger.test_write
    string = File.readlines('tmp.log').first
    string.should.equal "Hey, it worke"
  end
end
