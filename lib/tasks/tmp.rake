namespace :tmp do 
  namespace :assets do 
    desc "Clears javascript/cache and stylesheets/cache"
    task :clear => :environment do 
      FileUtils.rm(Dir['public/javascripts/cache/[^.]*'])
      FileUtils.rm(Dir['public/stylesheets/cache/[^.]*'])
    end
  end
end
