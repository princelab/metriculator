#!/usr/bin/env ruby
require 'os'
# System dependent locations
if OS.windows?
	Orbi_drive = "O:\\"
	Jtp_drive = "S:\\RAW\\"
	Database = "S:\\"
else
	Orbi_drive = "#{ENV["HOME"]}/chem/orbitrap/"
	Jtp_drive = "#{ENV["HOME"]}/chem/lab/RAW/"
	Database = "#{ENV["HOME"]}/chem/lab/"
end
Jtp_mount = MountedServer::MountMapper.new(Jtp_drive)
Orbi_mount = MountedServer::MountMapper.new(Orbi_drive)
Db_mount = MountedServer::MountMapper.new(Database)
	# I'm thinking that we can have a smart mount that knows your windows/linux location and thereby knows the actual location of every file you might need within the file structure.
=begin
	root = ..group/user/YYYYMM/experiment_name/
	./init/ Files pertinent to the initialization of the data such as the TUNE and METHOD and UPLC files.
	./metrics/ All the metrics stuff
	./ident/ identification analysis
	./quant/ quantification analysis
	./results/ Results of the analysis
	./graphs/ graphs of the Metrics and UPLC results (SO the HTML will rest here!)
	./samplename(s).RAW
	./mzML/ The mzXML and mzML files
	./config.yml
	./archive/ 	ANY other log files, or previous config files that might be stored
=end

class ArchiveMount
	def initialize(msrun)
		@msrun = msrun
	end
@@build_directories = ['init', 'metrics', 'ident', 'quant', 'results', 'graphs', 'mzML', 'archive']
#@location = [group, user, mtime, experiment_name]
	def build_archive # @location == LOCATION(group, user, mtime, experiment_id)
		# cp the config file from the higher level down
		@@build_directories.each do |dir|
			mkdir dir
		end
# Find a config file and move it down to this directory... right?

	end

	def to_mount
		define_location
		build_archive
	end

	def load_config
		@config = YAML.load_file(@settings)
	end

# @location == LOCATION(group, user, mtime, experiment_name)
	def define_location
		@location = [@msrun.group, @msrun.user, File.mtime(@msrun.rawfile), @msrun.rawid]
	end



end

CygBin = "C:\\cygwin\\bin"
CygHome = "C:\\cygwin\\home\\LTQ2"
UserHost = 'ryanmt@jp1'
ProgramLocale = '/home/ryanmt/Dropbox/coding/ms/archiver/lib/archiver.rb'
def send_msruninfo_to_linux_via_ssh(object)
	File.open('tmp.yml', 'w') {|out| YAML.dump(object, out)}
	file_move = %Q[#{CygBin}\\scp tmp.yml #{UserHost}:/tmp/]
	kick = %Q[#{CygBin}\\ssh #{UserHost} -C '#{ProgramLocale} --linux /tmp/tmp.yml ']
	%x[#{kick}]
	kick
end
