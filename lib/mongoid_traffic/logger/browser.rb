require 'user_agent'

module MongoidTraffic
  class Logger
    class Browser
      def initialize(user_agent_string)
        @user_agent_string = user_agent_string
      end

      def platform
        user_agent.platform
      end

      def name
        user_agent.browser
      end

      def version
        user_agent.version.to_s.split('.')[0..1].join('.')
      end

      private # =============================================================

      def user_agent
        @user_agent ||= ::UserAgent.parse(@user_agent_string)
      end
    end
  end
end
