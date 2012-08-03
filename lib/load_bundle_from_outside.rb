if $0 =~ /metriculator/
  ENV['RAILS_ENV'] ||= 'development'
  require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
else
  binding.pry
end
require 'archiver'
entries = Dir.entries(File.join(Dir.pwd, 'app', 'models')).select {|e| e =~ /.*\.rb$/ }
entries.each {|e| require e }


