# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_traffic/version'

Gem::Specification.new do |spec|
  spec.name          = 'mongoid_traffic'
  spec.version       = MongoidTraffic::VERSION
  spec.authors       = ['Tomáš Celizna']
  spec.email         = ['tomas.celizna@gmail.com']
  spec.description   = 'Aggregated traffic logs stored in MongoDB.'
  spec.summary       = 'Aggregated traffic logs stored in MongoDB.'
  spec.homepage      = 'https://github.com/tomasc/mongoid_traffic'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'mongoid', '>= 5', '< 8'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'database_cleaner', '~> 1.5.2'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-around'
  spec.add_development_dependency 'rake', '~> 10.0'
end
