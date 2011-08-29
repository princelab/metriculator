# This is the function that handles all the Message passing for this application
class Messenger
	class << self
    @@logs = {}

    # There need to be some locations defined, relative to the mount, for three files here... A queue, and two completed lists.  
    require_relative 'config.rb'
# This holds a hash directory of the node parameters
    Nodes = AppConfig[:nodes]
# This is the function which sets up the appropriate logging environment and the tasks to be performed by the process
    def setup
      @@logs ||= find_files( ArchiveRoot)
      find_files(location) if @@logs.empty?
      @@todo = File.readlines(@@logs[:todo])-File.readlines(@@logs[:metrics])
    end
    
# TESTING Fxns... Written to allow me to unit test the inside fxnality of this class
    def test_write
      find_files(Dir.pwd)
      @@logs[:todo] = 'tmp.log'
      write_message("Hey, it worked")
    end
# Another testing function
    def set_test_location(location)
      find_files(location)
    end    
# This allows me to read the logs
    def read_logs
      @@logs
    end
# This lets me read the todo list
    def read_todo
      @@todo
    end
    private
    def find_files(location)
      @@logs = {:todo => File.join(location, "todo.log"), 
        :metrics => File.join(location, "metrics.log")
      }
    end
    def write_message(string)
      File.open(@@logs[:todo], 'a') {|out| out.puts string }
    end
  end  
end # Messenger

