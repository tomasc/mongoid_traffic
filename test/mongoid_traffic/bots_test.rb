require 'test_helper'

require_relative '../../lib/mongoid_traffic/bots'

module MongoidTraffic
  describe 'Bots' do

    describe '.consume' do
      it 'fetches the allagents.xml' do
        skip 'to keep test fast'
        Bots.consume.must_be :present?
      end
    end

    describe '.list' do
      it 'parses the allagents.xml and converts it into Array of referers' do
        # skip 'to keep test fast'
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