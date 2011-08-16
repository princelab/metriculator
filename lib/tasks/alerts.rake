
namespace :db do 
  desc 'Clears the database and repopulates the alerts with a factoried list of alerts for testing the email and alert system'
  task :seed_alerts => :environment do 
    Alert.all.destroy
    a = Alert.create(:description => 'hello')
    b = Alert.create(:description => 'hello')
    FactoryGirl.create_list(:alert, 20)
  end
end

namespace :app do
  desc "Prints load path of this app"
  task :load_paths => :environment do
    Rails.configuration.load_paths.each do |p|
      puts p
    end
  end
end

