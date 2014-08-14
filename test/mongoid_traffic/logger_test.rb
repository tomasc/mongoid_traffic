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

    describe 'ClassMethods' do
      describe '.log' do

        before do 
          Logger.log(user_agent: user_agent_string, referer: referer, ip_address: ip_address)
          Logger.log(scope: scope, user_agent: user_agent_string, referer: referer, ip_address: ip_address)
        end

        it 'logs for month' do
          p Log.monthly(month, year).to_a
          Log.monthly(month, year).count.must_equal 1
        end
        it 'logs for date' do
          Log.daily(date).count.must_equal 1
        end
        it 'logs for scope' do
          Log.for_scope(scope).count.must_equal 2
        end
        it 'logs access_count' do
          Log.first.access_count.must_equal 1
        end
        it 'logs user_agent' do
          Log.first.browsers.fetch('Macintosh').fetch('Safari').fetch('8%2E0').must_equal 1
        end
        it 'logs referer' do
          Log.first.referers.fetch('http%3A%2F%2Fwww%2Egoogle%2Ecom').must_equal 1
        end
        it 'logs country' do
          Log.first.countries.fetch('DE').must_equal 1
        end
        it 'logs updated_at' do
          Log.first.updated_at.must_be :present?
        end

        describe 'when referer a bot' do
          let(:referer) { 'Googlebot/Test ( http://www.googlebot.com/bot.html)' }
          it 'does not create log' do
            Log.unscoped.wont_be :exists?
          end
        end
        
      end
    end

  end
end