require 'test_helper'

require_relative '../../../lib/mongoid_traffic/logger/referer'

module MongoidTraffic
  class Logger
    describe 'Referer' do
      let(:referer_string) { 'http://www.google.com:80/path/to?foo=bar' }
      subject { Referer.new(referer_string) }

      it 'strips protocol' do
        subject.host.wont_include 'http://'
      end

      it 'strips port' do
        subject.host.wont_include ':80'
      end

      it 'strips path' do
        subject.host.wont_include '/path/to'
      end

      it 'strips query params' do
        subject.host.wont_include '?foo=bar'
      end
    end
  end
end
