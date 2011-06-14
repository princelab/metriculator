source 'http://rubygems.org'

RAILS_VERSION = '~> 3.0.7'
DM_VERSION    = '~> 1.1.0'

gem 'activesupport',      RAILS_VERSION, :require => 'active_support'
gem 'actionpack',         RAILS_VERSION, :require => 'action_pack'
gem 'actionmailer',       RAILS_VERSION, :require => 'action_mailer'
gem 'railties',           RAILS_VERSION, :require => 'rails'

gem 'dm-rails',          '~> 1.1.0'
gem 'dm-sqlite-adapter', DM_VERSION
gem 'will_paginate', '3.0.pre2'

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

group :development do 
  gem 'rspec-rails', "~> 2.4"
  gem 'autotest', '4.4.6'
  gem 'autotest-rails-pure', '4.1.2'
  gem 'ZenTest'
  gem 'annotate-models', '1.0.4'
  gem 'faker', '0.3.1'

  # To get a detailed overview about what queries get issued and how long they take
  # have a look at rails_metrics. Once you bundled it, you can run
  #   rails g rails_metrics Metric
  #   rake db:automigrate
  # to generate a model that stores the metrics. You can access them by visiting
  #   /rails_metrics
  # in your rails application.
  gem 'rails_metrics', '~> 0.1', :git => 'git://github.com/engineyard/rails_metrics'


end

group :test do 
  gem 'rspec-rails', "~> 2.4"
  gem 'webrat', '0.7.1'
  gem 'spork', '0.9.0.rc5'
  gem 'rspec'
  gem 'factory_girl_rails', '1.0'
  gem 'bacon'
  gem 'rcov'
end
