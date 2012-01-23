#Welcome to The Metric Tracker

Metric Tracker is a Ruby on Rails application for displaying and interacting with data from
mass spec proteomics experiments.


##Installation

###Dependencies

1. Ruby 1.9:
   The installation process assumes you have a working Ruby installation of
   at least version 1.9.

   Make sure you have the correct version of Ruby:

       ruby --version

   I see:

       ruby 1.9.2p290 (2011-07-09 revision 32553) [x86_64-darwin11.1.0]

   which is 1.9, so I am okay.

   If you need help installing Ruby, see the
   [Ruby home page](http://www.ruby-lang.org/en/downloads/).
   We reccomend RVM as the installation option if it is available for your
   platform, but pick the one that seems best to you.

2. You also need a working RubyGems installation, and the `bundler` gem
   installed.

       gem install bundler

3. The [SQLite](http://www.sqlite.org/) database. You may already have
   it installed, so check before installing it again.

4. [R](http://r-project.org)

5. The `Rserve` and `beanplot` packages for R.
   If you are unfamiliar with the process of installing R packages,
   the following two commands, run from R, should suffice to install the packages.

       install.packages('Rserve', 'http://www.rforge.net/')
       install.packages('beanplot')

###Installing The Metric Tracker

Check out the project and install the required Gems:

    git co git://github.com/princelab/rails-metric_site.git %% cd rails-metric_site
    bundle install # this sets up the required libraries for running the site

This will require the installation of a dev-kit when running in windows.
Fortunately, there are instructions provided when bundle install fails.
When that has been done, bundle install again.

We also need to setup the `archiver` gem, which contains much of the
functionality for working with the metrics.

    gem build archiver.gemspec
    gem install archiver-0.0.1.gem

Now you need to set up the database configuration via the `database.yml`
file. There is an example file in `config/database.yml.example`.

    cp config/database.yml.example config/database.yml

You need to edit the `config/database.yml` file so the database paths point to where you
want your databases to be stored. The file has `<%ChangeThisVariableBlock %>`
where you need to provide a valid path. The file does not need to exist
yet, but the folder the file will be in does need to exist. For example,
my development database on line 9 of the file reads:
`database: /Users/jergason/Dropbox/prince_lab_stuff/rails-metric_site/db/metrics_site_test.db`.


Now we set up the database:

    bundle exec rake db:automigrate


Unfortunately, the webserver aspect of this will also require some effort,
at least for the best user experience possible.  To that end, it should
be achievable by following the directions that are given when you run:

    gem install passenger

and

    passenger-install-apache2-module

[Source: http://www.modrails.com/install.html ]

##Running The Metric Tracker

Rserve must be running. From within R, run the following commands:

    library('Rserve')
    Rserve()

This wills start Rserve as a daemon in the background.

Now start the metric tracker server of choice. If you want to use the
built-in server that comes with Rails, run:

    bundle exec rails s

Now go to [http://localhost:3000](http://localhost:3000) to see the site
in action.
