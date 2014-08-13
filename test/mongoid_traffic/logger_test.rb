require 'test_helper'

require_relative '../../lib/mongoid_traffic/logger'

module MongoidTraffic
  describe 'Logger' do

    describe 'ClassMethods' do
      describe '.log' do

        describe 'when records for current date do not exist' do
          let(:record_id) { 'foo/bar' }
          before { Logger.log(record_id) }

          it 'creates Log for year & month' do
            Log.for_record_id(record_id).for_month(Date.today.year, Date.today.month).where(access_count: 1).exists?.must_equal true
          end
          it 'creates Log for full date' do
            Log.for_record_id(record_id).for_date(Date.today).where(access_count: 1).exists?.must_equal true
          end
        end
        
      end
    end

  end
end