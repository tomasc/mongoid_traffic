require 'mongoid_traffic/version'

require 'mongoid_traffic/controller_additions'
require 'mongoid_traffic/log'
require 'mongoid_traffic/logger'

module MongoidTraffic
  TIME_SCOPE_OPTIONS = { year: 3, month: 2, week: 1, day: 0 }.freeze
end
