require 'bundler/setup'
require 'database_cleaner'

require 'minitest'
require 'minitest/around'
require 'minitest/autorun'
require 'minitest/spec'

require 'mongoid'
require 'mongoid_traffic'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

if ENV["CI"]
  require "coveralls"
  Coveralls.wear!
end

class MyLog
  include Mongoid::Document
  include MongoidTraffic::Log

  additional_counter :c, as: :country
  additional_counter :b, as: :browser
end
