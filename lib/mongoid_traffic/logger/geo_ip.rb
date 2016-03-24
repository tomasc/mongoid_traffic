require 'geoip'

module MongoidTraffic
  class Logger
    class GeoIp
      DATA_URL = 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz'.freeze
      FILE_URL = 'vendor/mongoid_traffic/GeoIP.dat'.freeze

      class << self
        def geoip
          @geoip ||= ::GeoIP.new(FILE_URL)
        end

        def country_code2(str)
          geoip.country(str).country_code2
        end
      end
    end
  end
end
