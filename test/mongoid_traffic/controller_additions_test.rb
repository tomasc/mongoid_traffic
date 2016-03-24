require 'test_helper'

require_relative '../../lib/mongoid_traffic/controller_additions'

module MongoidTraffic
  describe 'ControllerAdditions' do
    before(:each) do
      @controller_class = Class.new
      @controller = @controller_class.new
      def @controller_class.helper_method(_name); end
      @controller_class.send(:include, MongoidTraffic::ControllerAdditions)
    end

    describe '.log_traffic' do
      it 'logs with :user_agent'
      it 'logs with :referer'
      it 'logs with :ip_address'
      it 'logs with :unique_id'
    end

    describe '.log_scoped_traffic' do
      it 'infers scope from request path'
    end
  end
end
