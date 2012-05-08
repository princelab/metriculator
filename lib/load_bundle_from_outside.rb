if $0 =~ /metriculator/
  ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
  require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
else
  binding.pry
end

entries = Dir.entries(File.join(Dir.pwd, 'app', 'models')).select {|e| e =~ /.*\.rb$/ }
entries.each {|e| require e }

# The information regarding the system type and archive root location
SysInfo = AppConfig[:nodes][:metrics]
# A constant telling subsequent processes the program type called
Node = :metrics
# A constant to make accessing the root directory for the archives easier
ArchiveRoot = SysInfo[:archive_root]
putsv "ArchiveRoot: #{ArchiveRoot}"
Program = SysInfo[:program_locale]
Messenger.setup

