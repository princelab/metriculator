class Messenger
	class << self

  # There need to be some locations defined, relative to the mount, for three files here... A queue, and two completed lists.  
  require_relative 'config.rb'
  Nodes = AppConfig[:nodes]

	def instrument
    location = Nodes[:instrument][:archive_root]
    find_files(location)
	end

	def server
    location = Nodes[:server][:archive_root]
	end

	def metrics
    location = Nodes[:metrics][:archive_root]
    find_files(location)
    todo = File.readlines(logs[:todo])-File.readlines(logs[:metrics])
	end
  def test_write
    Logs[:todo] = 'tmp.log'
    write_message("Hey, it worked")
  end
  private
  def find_files(location)
    Logs = {:todo => File.join(location, "todo.log"), 
      :metrics => File.join(location, "metrics.log")
    }
  end
  def write_message(string)
    File.open(Logs[:todo], 'a') {|out| out.puts string }
  end
    
end # Messenger

