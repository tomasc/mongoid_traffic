require 'test_helper'

require_relative '../../lib/mongoid_traffic/logger'

module MongoidTraffic
  describe 'Logger' do
    let(:scope) { 'foo/bar' }

    let(:date) { Date.today }
    let(:year) { date.year }
    let(:month) { date.month }
    let(:day) { date.day }

    describe 'ClassMethods' do
      describe '.log' do

        # describe 'when records for current date do not exist' do
        #   before { Logger.log(scope) }

        #   describe 'for month' do
        #     it 'creates Log for a scope' do
        #       Log.for_scope(scope).for_year(year).for_month(month).where(access_count: 1).exists?.must_equal true
        #     end
        #     it 'creates Log for all properties' do
        #       Log.for_year(year).for_month(month).where(access_count: 1).exists?.must_equal true
        #     end
        #   end

        #   describe 'for date' do
        #     it 'creates Log for a scope' do
        #       Log.for_scope(scope).for_date(date).where(access_count: 1).exists?.must_equal true
        #     end
        #     it 'creates Log for all properties' do
        #       Log.for_date(date).where(access_count: 1).exists?.must_equal true
        #     end
        #   end
        # end
        
      end

      describe 'user_agent' do
        let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/538.46 (KHTML, like Gecko) Version/8.0 Safari/538.46' }

        it 'extracts :browser_name' do
          Logger.new(user_agent: user_agent_string).browser_name.must_equal 'Safari'
        end
        it 'extracts :browser_version' do
          Logger.new(user_agent: user_agent_string).browser_version.must_equal '8_0'
        end
      end
    end

  end
end