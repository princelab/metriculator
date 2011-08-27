# This is the function that handles all the Message passing for this application
class Messenger
	class << self
    @@logs = {}

    # There need to be some locations defined, relative to the mount, for three files here... A queue, and two completed lists.  
    require_relative 'config.rb'
# This holds a hash directory of the node parameters
    Nodes = AppConfig[:nodes]
# This runs the setup for the instrument node
    def instrument
      location = Nodes[:instrument][:archive_root]
      find_files(location) if @@logs.empty?
    end

# This runs setup for the server node
    def server
      location = Nodes[:server][:archive_root]
    end

# This runs setup for the metrics node
    def metrics
      location = Nodes[:metrics][:archive_root]
      find_files(location) if @@logs.empty?
      todo = File.readlines(@@logs[:todo])-File.readlines(@@logs[:metrics])
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

