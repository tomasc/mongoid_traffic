require 'test_helper'

require_relative '../../../lib/mongoid_traffic/logger/browser'

module MongoidTraffic
  class Logger
    describe 'Browser' do

      let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/538.46 (KHTML, like Gecko) Version/8.0 Safari/538.46' }
      subject { Browser.new(user_agent_string) }

      it 'returns :platform' do
        subject.platform.must_equal 'Macintosh'
      end

      it 'returns :name' do
        subject.name.must_equal 'Safari'
      end

      it 'returns :version' do
        subject.version.must_equal '8.0'
      end

    end
  end
end