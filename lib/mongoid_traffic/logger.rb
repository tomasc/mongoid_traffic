require 'useragent'

require_relative './log'

module MongoidTraffic
  class Logger

    def self.log *args
      new(*args).log
    end

    # ---------------------------------------------------------------------

    def initialize property, options={}
      @property = property
      @options = options
    end

    def log

      %i(ym ymd).each do |scope|
        Log.collection.find(time_query(scope)).upsert(upsert_query)
        Log.collection.find(property_query.merge(time_query(scope))).upsert(upsert_query)
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

    def browser_path
      [platform, browser_name, browser_version].join('.')
    end

    def browser_name
      user_agent.browser
    end

    def browser_version
      user_agent.version.to_s.split('.')[0..1].join('_')
    end

    # ---------------------------------------------------------------------

    def property_query
      { p: @property }
    end

    def time_query scope
      case scope
      when :ym then { y: Date.today.year, m: Date.today.month, d: nil }
      when :ymd then { y: Date.today.year, m: Date.today.month, d: Date.today.day }
      end
    end

    private # =============================================================
    
    def user_agent
      @user_agent ||= ::UserAgent.parse(@options[:user_agent])
    end

  end
end
