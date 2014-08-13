require_relative './log'

module MongoidTraffic
  class Logger

    class << self
      def log options={}
        Log.collection.find(find_query(:m)).upsert(upsert_query)
        Log.collection.find(find_query(:d)).upsert(upsert_query)
      end

      def upsert_query
        { '$inc' => { ac: 1 } }
      end

      def find_query scope
        case scope
        when :m then { y: Date.today.year, m: Date.today.month, d: nil }
        when :d then { y: Date.today.year, m: Date.today.month, d: Date.today.day }
        end
      end

    end

  end
end