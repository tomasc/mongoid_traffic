require 'bundler/gem_tasks'
require 'rake/testtask'
 
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end
 
namespace :mongoid_traffic do
  require File.dirname(__FILE__) + "/lib/mongoid_traffic/logger/bots"
  require File.dirname(__FILE__) + "/lib/mongoid_traffic/logger/geo_ip"

  desc "output the list of bots"
  task :update_bots_data do
    `cd vendor/mongoid_traffic && curl -O #{MongoidTraffic::Logger::Bots::DATA_URL}`
  end

  desc "output the geoip.dat"
  task :update_geoip_data do
    `cd vendor/mongoid_traffic && curl -O #{MongoidTraffic::Logger::GeoIp::DATA_URL}`
    `cd vendor/mongoid_traffic && gunzip GeoIP.dat.gz`
  end

end

task :default => :test