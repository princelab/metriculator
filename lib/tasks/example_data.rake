namespace :db do 
  desc 'Put some example data into the databases, to provide both some example pages for perusal, and also some complete testing dta.  ATTN:  WIPES the previous DB entries'
  task :seed_example => :environment do 
    DataMapper.auto_migrate!
    met = Ms::NIST::Metric.new File.expand_path("spec/tfiles/metrics/single_metric.txt")
    if !met.to_database
      puts "error saving file to database"
      return false
    else 
      puts "Metric parsed and saved correctly"
    end
    a = Msrun.first_or_create(1)
    a.update!( user: "A. Einstein", group: "Watson", rawfile: File.expand_path('spec/tfiles/time_test.RAW'), methodfile: File.expand_path('spec/tfiles/BSA.meth'), tunefile: File.expand_path("spec/tfiles/example_tune.LTQTune"), hplcfile: File.expand_path("spec/tfiles/ek2_test.txt"), autosampler_vial: "2B04", inj_volume: 1.0, hplc_max_p: 6530, hplc_avg_p: 5406, hplc_std_p: 45, raw_md5_sum: Digest::MD5.new(File.read('spec/tfiles/time_test.RAW')), graphfile: File.expand_path('spec/tfiles/ek2_test.svg'), archive_location: File.dirname("spec/tfiles/tmp.log"))
  end
end
