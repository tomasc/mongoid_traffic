require 'test_helper'

require_relative '../../lib/mongoid_traffic/logger'

module MongoidTraffic
  describe 'Logger' do

    describe 'ClassMethods' do
      describe '.log' do

        describe 'when records for current date do not exist' do
          before { Logger.log }
          it 'creates them' do
            Log.for_month(Date.today.year, Date.today.month).exists?.must_equal true
            Log.for_date(Date.today).exists?.must_equal true
          end
        end
        
      end
    end

  end
end