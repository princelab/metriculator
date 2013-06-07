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

  desc "Seeds the metrics data and then generates some example Comparisons"
  task :website_seed => [:graph_cleanup, :seed_from_metrics] do 
    captive_num = [62, 15, 17, 13, 11, 9, 14]
    nano_num = [5, 18, 50, 58, 59, 54, 7, 46, 23, 47, 60, 48, 57]
    cap_descr = "Early CaptiveSpray"
    nano_descr = "Late NanoSpray"
    [[captive_num, cap_descr, nano_num, nano_descr],
      [["1", "4", "7", "9", "12", "15", "18", "21", "24", "27", "29", "32", "35", "37", "40", "43", "46", "49", "55", "57", "60"],"20%", ["2", "5", "10", "13", "16", "19", "22", "25", "30", "33", "38", "41", "44", "47", "53", "58", "61"], "30%"]].each do |a1,d1,a2,d2|
      firsts = Msrun.all(id: a1)
      seconds = Msrun.all(id: a2)
      comparison = Comparison.new
      comparison.msrun_firsts = firsts
      comparison.msrun_seconds = seconds
      comparison.first_description = d1
      comparison.second_description = d2
      comparison.save
      comparison.graph
      puts "Comparison generated for your convenience!"
    end
  end
end
