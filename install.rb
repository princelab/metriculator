#!/usr/bin/env ruby 

#This script will automate the installation process for the user.  

system 'gem install bundler'
system 'bundle install'

system 'rake install'


# Put out some statements to guide them through the process of modifying the path...

system 'rake install:path'

# Put out the configuration script stuff...

system 'ruby -I lib/ ./bin/archiver-install'


