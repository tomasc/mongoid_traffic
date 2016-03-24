require 'uri'

module MongoidTraffic
  class Logger
    class Referer
      def initialize(referer_string)
        @referer_string = referer_string
      end

      def host
        uri.host
      end

      def to_s
        @referer_string
      end

      private # =============================================================

      def uri
        URI.parse(@referer_string)
      end
    end
  end
end
