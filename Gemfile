source 'http://rubygems.org'

RAILS_VERSION = '~> 3.0.7'
DM_VERSION    = '~> 1.1.0'
gem 'rails', RAILS_VERSION
gem 'railties', RAILS_VERSION, :require => 'rails'
gem 'activesupport', RAILS_VERSION
gem 'actionpack', RAILS_VERSION
gem 'actionmailer', RAILS_VERSION

gem 'sqlite3-ruby', '1.3.2', :require => 'sqlite3'
gem 'dm-rails',          '~> 1.1.0'
gem 'dm-sqlite-adapter', DM_VERSION
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
gem 'dm-chunked_query'

gem 'os'
gem 'rserve-simpler', :require => 'rserve/simpler'
gem 'haml'
gem 'jquery-rails'
gem 'rspec'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development do
  gem 'hpricot'
  gem 'ruby_parser'
end

group :test do
  gem 'rspec-rails'
  gem 'webrat'
  gem 'spork'
  gem 'factory_girl_rails', '~> 1.1.rc1'
  #gem 'bacon'
  #gem 'rcov'

  # To get a detailed overview about what queries get issued and how long they take
  # have a look at rails_metrics. Once you bundled it, you can run
  #   rails g rails_metrics Metric
  #   rake db:automigrate
  # to generate a model that stores the metrics. You can access them by visiting
  #   /rails_metrics
  # in your rails application.
  #gem 'rails_metrics', :git => 'git://github.com/engineyard/rails_metrics'
end
