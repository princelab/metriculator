namespace :metriculator do 
  desc "I'm using this to load my proper environment so I can update the databases with new external data."
  task( :load_rawfiles, [:array]  => :environment ) do |t, args|
    argv = args.array
    require 'optparse'
    options = {}
    metriculator_optparse = OptionParser.new do |opts|
      opts.banner = "Usage: -m email@example.com file1.RAW ... file[n].raw"
      opts.banner = "This takes a RAW file, runs the NIST proteomics metrics on it, and parses the output metric data into the Archiver database and website for viewing. If you'd like, you can pass an email address for an automated alert when the metrics have completed"

      # Define options:
      opts.on('-m', '--email [email_address]', String, "Set an email address for a completion alert") do |addy|
        options[:email] = addy
      end
      opts.on('-v', '--verbose', "Set verbosity to on") do |v|
        $VERBOSE = v
      end

      opts.on_tail('-h', '--help', "Prints help information") do 
        puts opts
        exit
      end
    end
    metriculator_optparse.parse!(argv)
    files = argv.map do |f|
      unless File.extname( f ).casecmp('.RAW')
        puts "File doesn't appear to be a rawfile, so we are skipping it:"
        puts "Filename: #{f}"
        nil
      else
        f
      end
    end.compact
    files.each do |file|
      if Ms::ArchiveMount.under_mount?(file) 
        putsv "File is under mount..."
      else
        putsv "File not under mount... moving..."
        tmp_subdirectory = "metriculator_tmp_rawfiles"
        dest = Ms::ArchiveMount.cp_under_mount(file, tmp_subdirectory)
        relative_file = Ms::ArchiveMount.relative_path(dest)
      end
    file = relative_file ? relative_file : file
    msrun = Ms::MsrunInfo.new
    id = msrun.raw_only_archive(file)
    Messenger.add_todo msrun.rawfile
    # TODO Generate, parse, and database metric information
      ## Currently, this will happen from the metrics server... Should I address it differently?  No, I think that is a good way to handle it.
    # TODO clear tmp cache if necessary
      ## This will require something automated on the Metric server side, right?
    # TODO write alert to notify of completion
      ### Again, this should happen on the Metric server side of things, right?
    end # files.each
  end # task
end
