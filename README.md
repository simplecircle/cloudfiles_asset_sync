Cloudfiles Asset Sync gem
=========================

The `cloudfiles_asset_sync` gem adds a rake task for uploading rails assets to Rackspace Cloud Files.

Install
-------

### With Bundler

Add the `cloudfiles_asset_sync` gem to your Gemfile

    gem 'cloudfiles_asset_sync'

Then run `bundle instal`

### Without Bundler

Install the `cloudfiles_asset_sync` gem

    gem install 'cloudfiles_asset_sync'

Require the `cloudfiles_asset_sync` gem in your code

    require 'cloudfiles_asset_sync'


Configuration
-------------

In your rails project create a file named `config/cloudfiles.yml` with the following options:

    production: # Rails env
      username: "rackspace username" # Required
      api_key: "rackspace api key" # Required
      container: "container name" # Optional, default is to use your railsenv_applicationname, e.g. production_example_application
      region: "uk" # Optional, only add if you want to use the uk rackspace cloud files
      ttl: 2000 # Optional, set the ttl used for a container

Usage
-----

To upload all files in the projects public assets folder, simply run

    CloudfilesAssetSync.run

Rake Task
---------

The best way to use this gem is to add the folling rake task to your project in `lib/tasks/cloudfiles_asset_sync.rake`:

    namespace :assets do
      desc "Uploads all assets Rackspace Cloud Files"
      task :sync do
        CloudfilesAssetSync.run
      end
    end

Capistrano
----------

If you want to sync your assets when you deploy using Capistrano, add the following to your deploy file

    namespace :deploy do
      namespace :assets do
        task :sync, :roles => :web, :except => { :no_release => true } do
          run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:sync"
        end
      end
    end

    after "deploy:assets:precompile", "deploy:assets:sync"

Rails Configuration
-------------------

Finally, after you have run sync for the first time, don't forget to update your rails environment to point to your rackspace container. In `config/environments/production.rb` change the following to the url for your container.

    config.action_controller.asset_host = "http://xxxx.xxx.xxx.rackcdn.com"

