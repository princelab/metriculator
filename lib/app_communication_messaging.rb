# This is the function that handles all the Message passing for this application
class Messenger
	class << self

    # There need to be some locations defined, relative to the mount, for three files here... A queue, and two completed lists.  
    require_relative 'config.rb'
# This holds a hash directory of the node parameters
    Nodes = AppConfig[:nodes]
# This is the function which sets up the appropriate logging environment and the tasks to be performed by the process
    def setup
      @@logs ||= find_files(ArchiveRoot)
      find_files(location) if @@logs.empty?
      update
    end
# This will update the @@todo list 
    def update
      begin 
        @@todo = (File.readlines(@@logs[:todo])-File.readlines(@@logs[:metrics])).map(&:chomp)
      rescue StandardError => bang
        print "Error: File doesn't exist!! " + bang
      end
    end

# TESTING Fxns... Written to allow me to unit test the inside fxnality of this class
    def test_write
      write_message(:todo, "Hey, it worked")
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
      update
    end
# This function adds a completed item to the metrics file
    def add_metric(string)
      write_message(:metrics, string)
    end
# This function adds a completed item to the server file ### MAYBE?
    def add_server(string)

    end
# This function adds an item to the todo list
# @param [Location_relative_to_mount]
    def add_todo(string)
      write_message(:todo, string)
    end
    private
    def find_files(location)
      @@logs = {:todo => File.join(location, "todo.log"), 
        :metrics => File.join(location, "metrics.log")
      }
    end
    def write_message(log_file, string)
      File.open(@@logs[log_file], 'a') {|out| out.puts string }
    end
  end  
end # Messenger

