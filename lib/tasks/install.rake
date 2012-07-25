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
  # according to :  http://stackoverflow.com/questions/190168/persisting-an-environment-variable-through-ruby
  # There is no way to permanently edit the PATH from within a script, only for child processes
  bin_dir = File.join(Dir.pwd, 'bin')
  case RbConfig::CONFIG['host_os']
  when 'linux-gnu'
    system "PATH=#{bin_dir}:$PATH"
  when 'mingw32'
    require 'pry'
    #binding.pry
    path_tmp = %x{echo %PATH%}.sub('PATH=','').gsub("\"","")#.split(";").join('";"')
    unless path_tmp[bin_dir]
      puts "Dear User:\n\tPlease run the following command, which will add the executables to your path.  This will make using the software possible."
      output =  %Q|setx $env:Path "#{bin_dir};#{path_tmp.chomp}"|
      puts output
      puts %Q|setx PATH "$env:path;#{bin_dir}" -m |
    end
    #system output
    #puts "PATH DIFF::: "
    #puts path_tmp.split(";").join('";"').split(";") - %x{echo %PATH%}.sub("PATH=","").split(";").join('";"').split(";")
end
  # This way I can still automate, but I'm not building the gem... retaining the local environment
 # Rake::Task['build'].invoke
 # system "gem install archiver-*"
end
