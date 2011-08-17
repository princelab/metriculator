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

gem 'dm-migrations',        DM_VERSION
gem 'dm-types',             DM_VERSION
gem 'dm-validations',       DM_VERSION
gem 'dm-constraints',       DM_VERSION
gem 'dm-transactions',      DM_VERSION
gem 'dm-aggregates',        DM_VERSION
gem 'dm-timestamps',        DM_VERSION
gem 'dm-observer',          DM_VERSION
gem 'dm-chunked_query'

gem 'pony'
gem 'rserve-simpler', :require => 'rserve/simpler'
gem 'haml'
gem 'jquery-rails'
gem 'rspec'
gem 'rake', "0.8.7"
# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development do
  gem 'hpricot'
  gem 'ruby_parser'
  gem 'ruby-debug19'
end

group :development, :test do
  # dependency of guard if on Mac OS X
  if RUBY_PLATFORM =~ /darwin/i
    gem 'rb-fsevent'
    gem 'growl'
    gem 'growl_notify'
  end
  # gem 'guard-rspec'
  # gem 'guard-bundler'
  gem 'autotest'
  gem 'autotest-fsevent'
  gem 'autotest-growl'
  gem 'autotest-rails'
  gem 'factory_girl_rails', '~> 1.1.rc1'
  gem 'rspec-rails'
end

group :test do
  gem 'webrat'
  # gem 'spork'
  gem 'capybara'
end
