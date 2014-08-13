require 'test_helper'

require_relative '../../lib/mongoid_traffic/logger'

module MongoidTraffic
  describe 'Logger' do
    let(:date) { Date.today }
    let(:year) { date.year }
    let(:month) { date.month }
    let(:day) { date.day }

    let(:scope) { 'foo/bar' }
    let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/538.46 (KHTML, like Gecko) Version/8.0 Safari/538.46' }
    let(:referer) { 'http://www.google.com' }

    describe 'ClassMethods' do
      describe '.log' do

        describe 'when records for current date do not exist' do
          before { Logger.log(scope: scope, user_agent: user_agent_string, referer: referer) }

          it 'logs for year & month' do
            Log.unscoped.for_year(year).for_month(month).must_be :exists?
          end
          it 'logs for date' do
            Log.unscoped.for_date(date).must_be :exists?
          end
          it 'logs for scope' do
            Log.unscoped.for_scope(scope).must_be :exists?
          end
          it 'logs access_count' do
            Log.unscoped.first.access_count.must_equal 1
          end
          it 'logs user_agent' do
            Log.unscoped.first.browsers.fetch('Macintosh').fetch('Safari').fetch('8%2E0').must_equal 1
          end
          it 'referer' do
            Log.unscoped.first.referers.fetch('www%2Egoogle%2Ecom').must_equal 1
          end
        end
        
      end
    end

  end
end