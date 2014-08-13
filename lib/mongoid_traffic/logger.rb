require_relative './log'

module MongoidTraffic
  class Logger

    class << self

      def log record_id, options={}
        @record_id = record_id

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
      
      def record_id_query
        { rid: @record_id }
      end

      def find_query scope
        case scope
        when :ym then record_id_query.merge!({ y: Date.today.year, m: Date.today.month, d: nil })
        when :ymd then record_id_query.merge!({ y: Date.today.year, m: Date.today.month, d: Date.today.day })
        end
      end

    end

  end
end