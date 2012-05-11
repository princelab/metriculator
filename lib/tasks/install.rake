$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

task :set_source_config do 
  # How can I salvage this loading?  I'm pretty sure I need to send something through
  # my executables...  Something like '$CONFIG_DIR' which sets the location of the
  # actual program install?  The gem really should just be the exectutables???  
  # Should I restructure to accomplish just that?
end


task :build do 
  system "gem build archiver.gemspec"
end

task :release => :build do 
  system "gem push archiver-*"
end

task :install do # => :build do 
  # TODO get this to create modify path or provide a command to modify the path to the user with instructions
  puts "Dear User:\n\tPlease run the following command, which will add the executables to your path.  This will make using the software easier."
  bin_dir = File.join(Dir.pwd, 'bin')
  case RbConfig::CONFIG['host_os']
  when 'linux-gnu'
    system "PATH=#{bin_dir}:$PATH"
  when 'mingw32'
    system "setx path=#{bin_dir};%PATH%"
  end
  # This way I can still automate, but I'm not building the gem... retaining the local environment
 # Rake::Task['build'].invoke
 # system "gem install archiver-*"
end
