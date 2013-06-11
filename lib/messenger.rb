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
      puts ArchiveRoot
      find_files(location) if @@logs.empty?
      @@logs.each do |name,file|
	unless File.size?(file)
	  FileUtils.touch(file)
	end
      end
      update
    end
# This will update the @@todo list 
# @return Array An array of todo list items.  These are paths which are relative with respect to the mount.
    def update
      @@todo = []
      tmp = 0
      begin 
        tmp +=1
        @@todo << (File.readlines(@@logs[:todo])-File.readlines(@@logs[:metrics])-File.readlines(@@logs[:error])-File.readlines(@@logs[:working])).map(&:chomp)
      rescue StandardError => bang
        puts "Error: Hacking a fix assuming a windows machine... \n" + bang.message
        find_files(AppConfig[:nodes][:metrics][:archive_root])
        retry unless tmp > 1
        puts "Error: File doesn't exist!!\n" + bang.message + "\n" + bang.backtrace.join("\n")
      end
      @@todo.flatten.compact
    end
# This function will clear the completed items of out the logs, leaving only uncompleted items.  This can run periodically to keep things nice and clean
    def clear_completed!
      update
      [@@logs[:todo], @@logs[:metrics]].each do |file|
	puts "FILE: #{file.inspect}"
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
# This function adds to the error list
# @param [Location_relative_to_mount]
    def add_error(string)
      write_message(:error, string)
    end
# This function adds to the working list
# @param [Location_relative_to_mount]
    def add_working(string)
      write_message(:error, string)
    end
# This fxn removes any completed items from the working
    def clear_finished
      unfinished = File.readlines(@@logs[:working])-File.readlines(@@logs[:metrics])
      unfinished.each do |f|
	add_working(f)
      end
    end
    private
# This function defines the location of the log files
    def find_files(location)
      @@logs = {:todo => File.join(location, "todo.log"), 
        :metrics => File.join(location, "metrics.log"), 
	:error => File.join(location, "error.log"),
	:working => File.join(location, "working.log")
      }
    end
# This function writes to the specified log file
    def write_message(log_file, string)
      File.open(@@logs[log_file], 'a') {|out| out.puts string }
    end
  end  
end # Messenger

