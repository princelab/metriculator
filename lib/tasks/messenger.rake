namespace :messenger do 
  desc "regenerate the messenging system files"
  task :regenerate => :environment do 
    Messenger.empty_root!
    Messenger.setup
  end
end
