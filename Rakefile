require 'bundler/gem_tasks'
require 'rake/testtask'
 
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end
 
namespace :mongoid_traffic do
  require File.dirname(__FILE__) + "/lib/mongoid_traffic/bots"

  desc "output the list of bots from http://www.user-agents.org/"
  task :update_bots do
    File.open(MongoidTraffic::Bots::FILE_PATH, 'w') { |file| file.write(MongoidTraffic::Bots.consume) }
  end

end

task :default => :test