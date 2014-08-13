require_relative './log'

module MongoidTraffic
  class Logger

    class << self

      def log property, options={}
        @property = property

        %i(ym ymd).each do |scope|
          Log.collection.find(find_query(scope)).upsert(upsert_query)
        end
      end

      # ---------------------------------------------------------------------
      
      def access_count_query
        { ac: 1 }
      end

      def upsert_query
        { '$inc' => access_count_query }
      end

      # ---------------------------------------------------------------------
      
      def property_query
        { p: @property }
      end

      def find_query scope
        case scope
        when :ym then property_query.merge!({ y: Date.today.year, m: Date.today.month, d: nil })
        when :ymd then property_query.merge!({ y: Date.today.year, m: Date.today.month, d: Date.today.day })
        end
      end

    end

  end
end