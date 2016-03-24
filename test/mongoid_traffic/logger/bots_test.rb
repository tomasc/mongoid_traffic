require 'test_helper'

require_relative '../../../lib/mongoid_traffic/logger/bots'

module MongoidTraffic
  class Logger
    describe 'Bots' do
      describe '.list' do
        it 'parses the allagents.xml and converts it into Array of referers' do
          Bots.list.must_be_kind_of Array
        end
      end

      describe '.is_a_bot?' do
        it 'detects referer in the bot list' do
          Bots.is_a_bot?('Googlebot/Test ( http://www.googlebot.com/bot.html)').must_equal true
        end
      end
    end
  end
end
