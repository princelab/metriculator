# This is the function that handles all the Message passing for this application
class Messenger
	class << self

    # There need to be some locations defined, relative to the mount, for three files here... A queue, and two completed lists.  
    require_relative 'config.rb'
# This holds a hash directory of the node parameters
    Nodes = AppConfig[:nodes]
# This is the function which sets up the appropriate logging environment and the tasks to be performed by the process
    def setup
      puts "ArchiveRoot: #{ArchiveRoot}"
      @@logs ||= find_files(ArchiveRoot)
      find_files(location) if @@logs.empty?
      update
    end
# This will update the @@todo list 
    def update
      @@todo = []
      tmp = 0
      begin 
        tmp +=1
        @@todo << (File.readlines(@@logs[:todo])-File.readlines(@@logs[:metrics])).map(&:chomp)
      rescue StandardError => bang
        find_files(AppConfig[:nodes][:server][:archive_root])
        print "Error: Hacking a fix... " + bang.message
        retry unless tmp > 1
        print "Error: File doesn't exist!!" + bang.message + bang.backtrace.join("\n")
      end
      @@todo.flatten.compact
    end
    def clear_completed!
      update
      @@logs.each do |k, file|
        FileUtils.rm(file)
        FileUtils.touch(file)
      end
      @@todo.each do |line|
        add_todo(line)
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
# This function defines the location of the log files
    def find_files(location)
      @@logs = {:todo => File.join(location, "todo.log"), 
        :metrics => File.join(location, "metrics.log")
      }
    end
# This function writes to the specified log file
    def write_message(log_file, string)
      File.open(@@logs[log_file], 'a') {|out| out.puts string }
    end
  end  
end # Messenger

