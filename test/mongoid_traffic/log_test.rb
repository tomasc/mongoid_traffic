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

      it 'has :scope' do
        subject.must_respond_to :scope
      end

      it 'has :access_count' do
        subject.must_respond_to :access_count
      end

      it 'has :browsers' do
        subject.must_respond_to :browsers
        subject.browsers.must_be_kind_of Hash
      end

      it 'has :referers' do
        subject.must_respond_to :referers
        subject.referers.must_be_kind_of Hash
      end

    end

  end
end