require 'spec_helper'

describe 'Messaging' do
  before :each do 
    ['spec/tfiles/todo.log', 'spec/tfiles/metrics.log'].each {|a| File.delete(a); FileUtils.touch(a) }
    p "RyanError" if not File.zero?('spec/tfiles/todo.log')
    Messenger.set_test_location('spec/tfiles')
  end

  it 'writes a message to the file' do 
    Messenger.test_write
    string = File.readlines('spec/tfiles/tmp.log').first.chomp
    string.should == "Hey, it worked"
  end
  it 'reads a todo list' do 
    Messenger.setup
    Messenger.test_write
    reply = Messenger.read_todo
    reply.class.should == Array
    reply.first.chomp.should == "Hey, it worked"
  end
  it 'adds a message, and then marks it completed' do 
    Messenger.add_todo('hello')
    a = Messenger.read_todo
    a.include?("hello").should == true
    Messenger.add_metric(a.first)
    b = Messenger.read_todo
    b.should == []
  end
  it 'should have the function to clear the logs of completed items' do
    Messenger.add_todo(File.absolute_path(__FILE__))
    Messenger.add_todo(File.absolute_path($0))
    a = Messenger.read_todo 
    a.size.should == 2 
    Messenger.add_metric(a.first)
    Messenger.clear_completed
    a = Messenger.read_todo
    a.size.should == 1
    a.should == [File.absolute_path($0)]
  end
end
