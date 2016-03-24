# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_traffic/version'

Gem::Specification.new do |spec|
  spec.name          = "mongoid_traffic"
  spec.version       = MongoidTraffic::VERSION
  spec.authors       = ["Tomáš Celizna"]
  spec.email         = ["tomas.celizna@gmail.com"]
  spec.description   = %q{Aggregated traffic logs stored in MongoDB.}
  spec.summary       = %q{Aggregated traffic logs stored in MongoDB.}
  spec.homepage      = "https://github.com/tomasc/mongoid_traffic"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "geoip"
  spec.add_dependency "mongoid", "~> 5.1"
  spec.add_dependency "nokogiri"
  spec.add_dependency "useragent"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-around"
  spec.add_development_dependency "rake"
end
