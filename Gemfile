source 'http://rubygems.org'

gem 'rails', '3.0.7'
gem 'sqlite3-ruby', '1.3.2', :require => 'sqlite3'
gem 'gravatar_image_tag', '1.0.0.pre2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development do
  gem 'rspec-rails', '2.5.0'
  RAILS_VERSION = '~> 3.0.7'
  DM_VERSION    = '~> 1.1.0'
  gem 'railties',           RAILS_VERSION, :require => 'rails'
  gem 'dm-rails',          '~> 1.1.0'
  gem 'dm-sqlite-adapter', DM_VERSION
  gem 'os'
  gem 'rserve-simpler', require: 'rserve/simpler'


# You can use any of the other available database adapters.
# This is only a small excerpt of the list of all available adapters
# Have a look at
#
#  http://wiki.github.com/datamapper/dm-core/adapters
#  http://wiki.github.com/datamapper/dm-core/community-plugins
#
# for a rather complete list of available datamapper adapters and plugins

   gem 'dm-sqlite-adapter',    DM_VERSION
# gem 'dm-mysql-adapter',     DM_VERSION
# gem 'dm-postgres-adapter',  DM_VERSION
# gem 'dm-oracle-adapter',    DM_VERSION
# gem 'dm-sqlserver-adapter', DM_VERSION

  gem 'dm-migrations',        DM_VERSION
  gem 'dm-types',             DM_VERSION
  gem 'dm-validations',       DM_VERSION
  gem 'dm-constraints',       DM_VERSION
  gem 'dm-transactions',      DM_VERSION
  gem 'dm-aggregates',        DM_VERSION
  gem 'dm-timestamps',        DM_VERSION
  gem 'dm-observer',          DM_VERSION

  gem 'autotest', '4.4.6'
  gem 'autotest-rails-pure', '4.1.2'
  gem 'ZenTest'
  gem 'annotate-models', '1.0.4'
  gem 'faker', '0.3.1'
end

group :test do 
  gem 'webrat', '0.7.1'
  gem 'spork', '0.9.0.rc5'
  gem 'rspec'
  gem 'factory_girl_rails', '1.0'
  gem 'bacon'
  gem 'rcov'

  # To get a detailed overview about what queries get issued and how long they take
  # have a look at rails_metrics. Once you bundled it, you can run
  #   rails g rails_metrics Metric
  #   rake db:automigrate
  # to generate a model that stores the metrics. You can access them by visiting
  #   /rails_metrics
  # in your rails application.
  gem 'rails_metrics', '~> 0.1', :git => 'git://github.com/engineyard/rails_metrics'
end
