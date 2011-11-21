#!/usr/bin/env ruby 

# Verbose dependent printing statement
def putsv(string)
  puts string if $VERBOSE
end
require 'pry' 
require 'config'
require 'msruninfo'
require 'xcalibur'
require 'eksigent'
require 'optparse'
require 'archive_mount'
require 'app_communication_messaging'
# this package handles options and configures the packaging and archiving of 
# data produced by the instrument, as well as archiving of all the files used
# during the run 

options = {}
archiver_optparse = OptionParser.new do |opts|
		opts.banner = "Usage: #{__FILE__} [options] file1 file2 ..." 
		opts.banner = %Q{ This archives files.  Basically, it functions in one of three ways:  
    1. As a process to parse and archive files once the instrument is done with a run. 
    2. As a client which runs a server which allows for easy viewing of performance metrics and general file information, including a database which archives information regarding each file, which, for server responsiveness, should probably be a *NIX client.
    3. As a client on a windows machine which runs a NIST Metrics suite to generate the performance metrics data.
    These functions can be on separate boxes, or run on the same system, as the only requirement for each system is that they can access the same shared file directory.  We recommend offloading as much of the processing as is possible from the instrument computer.
    }
		#opts.banner = "RAW file should have this name format 'GROUP_username_sample-id-info.RAW'"
		#opts.banner = "Ex: JTP_ryanmt_xlinkingsample001.RAW"
		#opts.banner = "which will be archived under JTP/ryanmt/YYMM/JTP_ryanmt_x0linkingsample001/..."

# Define the options
	options[:verbose] = false
	opts.on( '-v', '--verbose') { options[:verbose] = true }

	options[:zipped] = false
	opts.on( '-z', '--zipped', 'Define if the archive will be zipped or not (FALSE)') { options[:zipped] = true}

#	options[:figure] = true
#	opts.on( '-f', '--figure', 'Output the figure graphing the NanoLC elution pressure trace (TRUE)') {options[:figure] = false}

	options[:mzxml] = true 
	opts.on('-n', '--no_mzxml', 'Do not output the mzxml files') {options[:mzxml] = false}

	options[:dry_run] = false
	opts.on( '-d', '--dry_run', 'Run analysis without moving files to archive locations (FALSE)') {options[:dry_run] = true}

	options[:move_files] = false
	opts.on( '-m', '--move_files', "Instead of just copying the files over to the archive, delete them, safely (checks that file has moved) (FALSE)") {options[:move_files] = true}

	options[:xcalibur] = false
	opts.on( '--xcalibur', 'Runs this as called from Xcalibur and on an analysis workstation(minimize work down here, move then finish), with appropriate defaults' ) do 
    options[:xcalibur] = true 
    if ARGV.size != 2
      puts "Archiver's 'Xcalibur' mode can't run without the input file and row number!"
      puts "Exiting..."
      exit
    end
  end

	options[:server] = false
	opts.on( '--server', 'Finishes the analysis, being fed a yaml file which represents the data collected previously, together with the archive location for the files.  These can then be completed by running the remaining options (like graphing, building metrics, and parsing the metrics to the database) ' ) {options[:server] = true }

  options[:metrics] = false
  opts.on( '--metrics', "Runs a special process which monitors a queue file and runs metric conversions on the specified files") {options[:metrics] = true}

  options[:server_setup] = false
  opts.on( '--server_setup', "Attempts to initialize all settings and configure the webserver to enable the best way to run for the OS of this machine.  If this is a Windows machine, it will run the rails WEBrick server, if it is a *NIX box, it will configure an Apache installation to run this server") {options[:server_setup] = true}
	opts.on('-h', '--help', 'Display this screen' ) do 
		puts opts
		exit
	end
end
##  Program starts here!!!! 

if File.basename($0) == 'archiver'
  archiver_optparse.parse!# outparse and PARSED!! 
end
if options[:verbose]
  $VERBOSE = 1
  putsv "Verbosity set to true"
end

if options[:xcalibur]
# The information regarding the system type and archive root location
  SysInfo = AppConfig[:nodes][:instrument]
# A constant telling subsequent processes the program type called
  Node = :instrument
# A constant to make accessing the root directory for the archives easier
  ArchiveRoot = SysInfo[:archive_root]
# Prep
	file = ARGV.shift
	line_num = ARGV.shift.to_i
	if ARGV.length > 0
		puts "Possible error: There are #{ARGV.length} arguments remaining in the program call..."
		puts "shouldn't you have not specified --xcalibur?"
		puts 'continuing........'
	end
# Real work
	raise FileTypeError if File.extname(file) != File.extname('Test.sld')
	sld = Ms::Xcalibur::Sld.new(file).parse
	object = Ms::MsrunInfo.new(sld.sldrows[line_num])
	object.grab_files
  Ms::ArchiveMount.new(object)
  Ms::ArchiveMount.build_archive
	Ms::ArchiveMount.archive
	send_msruninfo_to_linux_via_ssh(object.to_yaml)
end

if options[:server]
# The information regarding the system type and archive root location
  SysInfo = AppConfig[:nodes][:server]
# A constant telling subsequent processes the program type called
  Node = :server
# A constant to make accessing the root directory for the archives easier
  ArchiveRoot = SysInfo[:archive_root]
	yaml_file = ARGV.first
	object = YAML::load_file(yaml_file)
# Start the server
  # Rails server is limited to processing a single request at a time...
  # You should use Apache, probably.  Hence, configure things with passenger for a *NIX environment
  if SysInfo[:system] == "Windows"
    %x[ rails s]
  else
    %x[ passenger start ]
  end
end

if options[:metrics]
  # Metrics Gems:
  require 'rufus/scheduler'

# The information regarding the system type and archive root location
  SysInfo = AppConfig[:nodes][:metrics]
# A constant telling subsequent processes the program type called
  Node = :metrics
# A constant to make accessing the root directory for the archives easier
  ArchiveRoot = SysInfo[:archive_root]
  Program = SysInfo[:program_locale]
  Messenger.setup
  scheduler = Rufus::Scheduler::PlainScheduler.start_new(:thread_name => "NIST_metrics_daemon")
  scheduler.every '1m' do 
    putsv 'Checking todo list...'
    list = Messenger.update
    if list.size > 0
      putsv "Todo items found: #{list}"
    end
  end # every 1m
  scheduler.every '1d' do 
    # TODO Clear lists fxn
  end
  binding.pry
  scheduler.join
end

if options[:server_setup]
  # The information regarding the system type and archive root location
  SysInfo = AppConfig[:nodes][:server]
# A constant telling subsequent processes the program type called
  Node = :server
# A constant to make accessing the root directory for the archives easier
  ArchiveRoot = SysInfo[:archive_root]
  puts "Honestly, this is probably too ambitious of a project.  You'll have to configure your own server environment at this point."
end