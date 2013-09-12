#Welcome to The Metric Tracker

Metric Tracker is a Ruby on Rails application for displaying and interacting with data from
mass spec proteomics experiments.


##Installation
Read below about the dependencies.  To facilitate the process, I've generated a script which should help automate some of the process.  First, you will definitely need to install Ruby (step 1 below).  If you've done that then you can use git (step #2 below) to copy the repository to a local directory by running `git clone git://github.com/princelab/metriculator.git` . Once that is done, you can run `./bin/archiver-install` to run the automated installer.  Do this for each computer on which you'll be using archiver.

###Dependencies

1. Ruby 1.9:
   The installation process assumes you have a working Ruby installation of
   at least version 1.9.

        ruby --version

   If you need help installing Ruby, see the
   [Ruby home page](http://www.ruby-lang.org/en/downloads/).
   We recommend RVM as the installation option if it is available for your
   platform, but pick the one that seems best to you.

2. You should install git.  Git for windows can be found here: [Git for Windows](http://code.google.com/p/msysgit/).

3. You also need a working RubyGems installation, and the `bundler` gem
   installed.

        gem install bundler

4. The [SQLite](http://www.sqlite.org/) database. You may already have
   it installed, so check before installing it again.

### Automated Installation (RECOMMENDED)

Check out the project from git, and install the required gems:
  
    git clone https://github.com/princelab/metriculator.git 
    cd metriculator

Then try the automated configuration and installation tool: 

    ./bin/archiver-install 

### Configuring the Thermo Scientific Xcalibur hook

Once you have installed Metriculator as a data acquisition utility on a computer which performs data acquisition, we can configure it to automatically archive your files, and kick off other downstream analysis (metric generation, and other hooks like discussed in the section, [Custom Integrators](#Custom-Integrators).  
    

###Installing The Metric Tracker Manually

Check out the project and install the required Gems:

     git checkout git://github.com/princelab/metriculator.git %% cd metriculator
     bundle install # this sets up the required libraries for running the site

This will require the installation of a dev-kit when running in windows.
Fortunately, there are instructions provided when bundle install fails.
When that has been done, bundle install again.

Now you need to set up the database configuration via the `database.yml`
file. There is an example file in `config/database.yml.example`.

      cp config/database.yml.example config/database.yml

You need to edit the `config/database.yml` file so the database paths point to where you want your databases to be stored.  We'd recommend making the file in the shared storage location if you are running a distributed system.  The file has `<%ChangeThisVariableBlock %>` where you need to providhttp://www.modrails.com/documentation/Users%20guide%20Apache.htmle a valid path. The file does not need to exist yet, but the folder the file will be in does need to exist. For example, my development database on line 9 of the file reads: 
`database: /Users/jergason/Dropbox/prince_lab_stuff/metriculator/db/metrics_site_test.db`.  You'll only really need the production database unless you plan on developing.  

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

Start the server of choice. If you want to use the
built-in server that comes with Rails, run:

     bundle exec rails s

Now go to [http://localhost:3000](http://localhost:3000) to see the site
in action.

However, if you are configuring it for a more permanent (and faster) use, than you should use the passenger-apache method mentioned above.  Apache is somewhat challenging to configure, and I am hardly an expert, but have figured it out with Google searches before.  However, my situation was more complex, and you will likely have few problems with a simple installation.  Passenger has instructions on how to integrate with apache at [Passenger users guide, Apache edition](http://www.modrails.com/documentation/Users%20guide%20Apache.html).

## Custom Integrators
Metriculator provides a framework for integrating your own plugins and utilities to set points within the architecture.  Additional integration set points can be configured, and we would welcome pull-requests to accomplish those.

As way of example, you can read in [submit_to_xtandem_example.rb](lib/integrators/submit_to_xtandem_example.rb)

The current integration points are 
```ruby
    [:on_db_store, :on_finish, :on_parse]
```
#LICENSE
Released under the MIT license, as referenced in LICENSE



#Parting words
Above all, if you have problems, feel free to contact me via github, preferably after submitting an issue on github.  Thanks!
