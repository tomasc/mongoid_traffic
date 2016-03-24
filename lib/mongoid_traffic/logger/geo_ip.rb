require 'geoip'

module MongoidTraffic
  class Logger
    class GeoIp
      DATA_URL = 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz'.freeze
      FILE_PATH = File.join(File.dirname(__dir__), '..', '..', 'vendor', 'mongoid_traffic', 'GeoIP.dat')

      class << self
        def geoip
          @geoip ||= ::GeoIP.new(FILE_PATH)
        end

        def country_code2(str)
          geoip.country(str).country_code2
        end
      end
    end
  end
end
