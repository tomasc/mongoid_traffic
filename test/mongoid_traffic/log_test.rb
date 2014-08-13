require 'test_helper'

require_relative '../../lib/mongoid_traffic/log'

module MongoidTraffic
  describe 'Log' do

    subject { Log.new }

    describe 'fields' do
      it 'has :year' do
        subject.must_respond_to :year
      end

      it 'has :month' do
        subject.must_respond_to :month
      end

      it 'has :day' do
        subject.must_respond_to :day
      end

      it 'has :browsers' do
        subject.must_respond_to :browsers
        subject.browsers.must_be_kind_of Hash
      end

      it 'has :updated_at' do
        subject.must_respond_to :updated_at
      end
    end

  end
end