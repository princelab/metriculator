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
  desc "Cleans out the generated metric graphing files" 
  task :graph_cleanup do 
    list = Dir.glob(File.join(AppConfig[:comparison_directory], "*"))
    list.each {|dir| FileUtils.remove_dir(dir) }
    puts "Cleaned up #{AppConfig[:comparison_directory]}, it now has #{Dir.glob(File.join(AppConfig[:comparison_directory], "*")).size} files in it."
  end

  desc "Seeds the metrics data and then generates an example Comparison"
  task :website_seed => [:graph_cleanup, :seed_from_metrics] do 
    captive_num = [62, 15, 17, 13, 11, 9, 14]
    nano_num = [5, 18, 50, 58, 59, 54, 7, 46, 23, 47, 60, 48, 57]
    cap_descr = "Early CaptiveSpray"
    nano_descr = "Late NanoSpray"
    cap = Msrun.all(id: captive_num)
    nano = Msrun.all(id: nano_num)
    comparison = Comparison.new
    comparison.msrun_firsts = cap
    comparison.msrun_seconds = nano
    comparison.first_description = cap_descr
    comparison.second_description = nano_descr
    comparison.save
    comparison.graph
    puts "Comparison generated for your convenience!"
  end
end
