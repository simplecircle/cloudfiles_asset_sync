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
      container: "container name" # Optional, default is to use your rails application name
      region: "uk" # Optional, only add if you want to use the uk rackspace cloud files

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

