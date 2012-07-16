$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

task :build do 
  system "gem build archiver.gemspec"
end

task :release => :build do 
  system "gem push archiver-*"
end

task :install => :build do 
  # This is where I output the instructions to change their paths and handle the gem installations to make bundler and rake available... Wait... I do that in a ruby script, actually...
  system 'ruby install.rb'
end

namespace :install do 
  task :path do 
    
  end

end
