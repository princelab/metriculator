require 'msruninfo'
require 'xcalibur'
require 'eksigent'
require 'optparse'
require 'archive_mount'
require 'config'
# this package handles options and configures the packaging and archiving of 
# data produced by the instrument, as well as archiving of all the files used
# during the run 

options = {}
optparse = OptionParser.new do |opts|
		opts.banner = "Usage: #{__FILE__} [options] file1 file2 ..." 
		opts.banner = %Q{ This archives files.  Basically, it functions in one of three ways:  
    1. As a process to parse and archive files once the instrument is done with a run. 
    2. As a client which runs a server which allows for easy viewing of performance metrics and general file information, including a database which archives information regarding each file.
    3. As a client on a windows machine which runs a NIST Metrics suite to generate the performance metrics data
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
      puts "Xcalibur can't run without the input file and row number!"
      puts "Exiting..."
      exit
    end
  end

	options[:server] = false
	opts.on( '--server', 'Finishes the analysis, being fed a yaml file which represents the data collected previously, together with the archive location for the files.  These can then be completed by running the remaining options (like graphing, building metrics, and parsing the metrics to the database) ' ) {options[:server] = true }

  options[:metrics] = false
  opts.on( '--metrics', "Runs a special process which monitors a queue file and runs metric conversions on the specified files") {options[:metrics] = true}

	opts.on('-h', '--help', 'Display this screen' ) do 
		puts opts
		exit
	end
end.parse!   # outparse and PARSED!! 

if options[:xcalibur]
  SysInfo = AppConfig[:nodes][:instrument]
# Prep
	file = ARGV.shift
	line_num = ARGV.shift
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
	Ms::ArchiveMount.archive(object)
	send_msruninfo_to_linux_via_ssh(object.to_yaml)
end

if options[:server]
	yaml_file = ARGV.first
	object = YAML::load_file(yaml_file)


end

if options[:metrics]

end
