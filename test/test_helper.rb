require 'bundler/setup'
require 'database_cleaner'
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'mongoid'
require 'mongoid_traffic'

if ENV["CI"]
  require "coveralls"
  Coveralls.wear!
end

Mongoid.configure do |config|
  config.connect_to('mongoid_traffic_test')
end

DatabaseCleaner.orm = :mongoid
DatabaseCleaner.strategy = :truncation

class MiniTest::Spec
  before(:each) { DatabaseCleaner.start }
  after(:each) { DatabaseCleaner.clean }
end

class MyLog
  include Mongoid::Document
  include MongoidTraffic::Log
end
