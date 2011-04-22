
# ENV["HOME"] begins with /home/

# ENV["OS"] returns "Windows NT" on MSally
# System dependent locations
if ENV["HOME"][/\/home\//] == '/home/'
	Orbi_drive = "#{ENV["HOME"]}/chem/orbitrap/"
	Jtp_drive = "#{ENV["HOME"]}/chem/lab/RAW/"
	Database = "#{ENV["HOME"]}/chem/lab/"
elsif ENV["OS"][/Windows/] == 'Windows'
	Orbi_drive = "O:\\"
	Jtp_drive = "S:\\RAW\\"
	Database = "S:\\"
end

module MountedServer
	DEFAULT_PORT = 22907  # arbitrary
	MSCONVERT_CMD_WIN = "msconvert.exe"
# temporary directory under the server mount directory
	DEFAULT_MOUNT_TMP_SUBDIR = "tmp"
	CUE_FOR_HELP = "--help"

	def wrap_reply(st)
		"<reply>\n#{st}\n</reply>"
	end
end

module MountedServer
	class MountMapper
		include MountedServer
		attr_accessor :mount_dir
		attr_reader :mount_dir_pieces
		attr_accessor :tmp_subdir
		attr_accessor :archive_location, :windows_location, :linux_location, :metrics, :init, :graphs, :settings, :results, :analysis
		def initialize(mount_dir, tmp_subdir=MountedServer::DEFAULT_MOUNT_TMP_SUBDIR)
			@mount_dir = File.expand_path(mount_dir)
			@mount_dir_pieces = split_filename(@mount_dir)
			@tmp_subdir = tmp_subdir
		end
		def config
			YAML.load_file(self.settings)
		end
		# OS independent filename splitter "/path/to/file" =>
		# ['path','to','file']
		def split_filename(fn)
			fn.split(/[\/\\]/)
		end

		# OS independent basename getter
		def basename(fn)
			split_filename(fn).last
		end

		def under_mount?(filename)
			split_filename(File.expand_path(filename))[0,@mount_dir_pieces.size] == @mount_dir_pieces
		end

		# assumes the file is already under the mount
		# returns its path relative to the mount
		def relative_path(filename)
			pieces = split_filename(File.expand_path(filename))
			File.join(pieces[@mount_dir_pieces.size..-1])
		end

		# move the file under the mount.  If @tmp_subdir is defined, it will use that directory.
		# returns the expanded path of the file
		def cp_under_mount(filename)
			dest = File.join(@mount_dir, tmp_subdir || "", File.basename(filename))
			FileUtils.cp( filename, dest, preserve=true )
			dest
		end

		def cp_to(filename, mounted_dest) # Always returns the destination as an explicit location relative to the mount directory
			dest = File.join(@mount_dir, mounted_dest, File.basename(filename))
			puts 'DESTINATION:   															______________'
			p dest
			puts "mounted_dest: #{mounted_dest}"
			FileUtils.mkdir_p(dest)
			FileUtils.cp( filename, dest, preserve=true)
			dest
		end

		def full_path(relative_filename)
			File.join(@mount_dir, relative_filename)
		end
	end
end






#########################333333 RANDOM TIME GENERATOR!!!

class Time
	def self.random(years_back=1)
		year = Time.now.year - rand(years_back) - 1
		month = rand(12) + 1
		day = rand(31) + 1 
		hour = rand(23) + 1
		minute = rand(59) + 1
		Time.local(year, month, day, hour, minute)
	end
end
