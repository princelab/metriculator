namespace :db do
  desc 'drops the database and repopulates it with the contents of the test metric files'
  task :seed_from_metrics => :environment do
    DataMapper.auto_migrate!
    Dir["spec/tfiles/metrics/*.txt"].each do |file|
      met = Ms::NIST::Metric.new File.expand_path(file)
      if !met.to_database
        puts "error saving #{file} to database."
        return false
      else
        puts "Done with #{file} and I'm on to the next."
      end
    end
  end
end
