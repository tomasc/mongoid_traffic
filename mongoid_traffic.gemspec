# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_traffic/version'

Gem::Specification.new do |spec|
  spec.name          = 'mongoid_traffic'
  spec.version       = MongoidTraffic::VERSION
  spec.authors       = ["Tomáš Celizna"]
  spec.email         = ['tomas.celizna@gmail.com']
  spec.description   = 'Aggregated traffic logs stored in MongoDB.'
  spec.summary       = 'Aggregated traffic logs stored in MongoDB.'
  spec.homepage      = 'https://github.com/tomasc/mongoid_traffic'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'geoip'
  spec.add_dependency 'mongoid'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'useragent'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'database_cleaner', '~> 1.5.2'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-around'
  spec.add_development_dependency 'rake'
end
