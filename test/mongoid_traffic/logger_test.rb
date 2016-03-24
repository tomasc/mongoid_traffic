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
    let(:ip_address) { '88.198.50.152' }
    let(:unique_id) { 'ABC' }

    describe 'ClassMethods' do
      describe '.log' do
        before do
          MongoidTraffic::Logger.log(::MyLog, user_agent: user_agent_string, referer: referer, ip_address: ip_address, unique_id: unique_id)
          MongoidTraffic::Logger.log(::MyLog, scope: scope, user_agent: user_agent_string, referer: referer, ip_address: ip_address, unique_id: unique_id)
        end

        it 'logs for month' do
          ::MyLog.monthly(month, year).count.must_equal 1
        end
        it 'logs for date' do
          ::MyLog.daily(date).count.must_equal 1
        end
        it 'logs for scope' do
          ::MyLog.scoped_to(scope).count.must_equal 2
        end
        it 'logs access_count' do
          ::MyLog.first.access_count.must_equal 1
        end
        it 'logs user_agent' do
          ::MyLog.first.browsers.fetch('Macintosh').fetch('Safari').fetch('8%2E0').must_equal 1
        end
        it 'logs referer' do
          ::MyLog.first.referers.fetch('http%3A%2F%2Fwww%2Egoogle%2Ecom').must_equal 1
        end
        it 'logs country' do
          ::MyLog.first.countries.fetch('DE').must_equal 1
        end
        it 'logs unique_id' do
          ::MyLog.first.unique_ids.fetch('ABC').must_equal 1
        end
        it 'logs updated_at' do
          ::MyLog.first.updated_at.must_be :present?
        end

        describe 'when referer a bot' do
          let(:referer) { 'Googlebot/Test ( http://www.googlebot.com/bot.html)' }
          it 'does not create log' do
            ::MyLog.exists?.must_equal false
          end
        end
      end
    end
  end
end
