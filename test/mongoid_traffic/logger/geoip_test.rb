require 'test_helper'

require_relative '../../../lib/mongoid_traffic/logger/geo_ip'

module MongoidTraffic
  class Logger
    describe 'GeoIp' do

      describe '.consume' do
        it 'fetches the allagents.xml' do
          skip 'to keep test fast'
          GeoIp.consume.must_be :present?
        end
      end

    end
  end
end