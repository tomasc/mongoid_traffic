require 'test_helper'

require_relative '../../lib/mongoid_traffic/logger'

module MongoidTraffic
  describe 'Logger' do

    describe 'ClassMethods' do
      describe '.log' do

        describe 'when records for current date do not exist' do
          let(:property) { 'foo/bar' }
          before { Logger.log(property) }

          it 'creates Log for year & month' do
            Log.for_property(property).for_month(Date.today.year, Date.today.month).where(access_count: 1).exists?.must_equal true
          end
          it 'creates Log for full date' do
            Log.for_property(property).for_date(Date.today).where(access_count: 1).exists?.must_equal true
          end
        end
        
      end
    end

  end
end