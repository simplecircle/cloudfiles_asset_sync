ENV["RAILS_ENV"] = "test"
require 'bundler/setup'
require 'rails'
require File.join(File.dirname(__FILE__), '..', 'lib', 'cloudfiles_asset_sync')
require "test/unit"
require 'mocha'
