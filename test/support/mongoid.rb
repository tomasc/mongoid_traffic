require 'mongoid'

Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO

Mongoid.configure do |config|
  config.connect_to('mongoid_traffic_test')
end
