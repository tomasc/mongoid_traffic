require 'uri'
require 'useragent'

require_relative './log'
require_relative './logger/browser'
require_relative './logger/referer'

module MongoidTraffic
  class Logger

    def self.log *args
      new(*args).log
    end

    # ---------------------------------------------------------------------

    def initialize scope: nil, user_agent: nil, referer: nil
      @scope = scope
      @user_agent_string = user_agent
      @referer_string = referer
    end

    def log
      %i(ym ymd).each do |ts|
        Log.collection.find( find_query(ts) ).upsert( upsert_query )
      end
    end

    # ---------------------------------------------------------------------

    def upsert_query
      { '$inc' => access_count_query.merge(browser_query).merge(referer_query) }
    end

    # ---------------------------------------------------------------------

    def access_count_query
      { ac: 1 }
    end

    def browser_query
      return {} unless browser.present?
      browser_path = [browser.platform, browser.name, browser.version].map{ |s| escape_key(s) }.join('.')
      { "b.#{browser_path}" => 1 }
    end

    def referer_query
      return {} unless referer.present?
      referer_key = escape_key(referer.host)
      { "r.#{referer_key}" => 1 }
    end

    # ---------------------------------------------------------------------
    
    def escape_key key
      key.gsub('.', '%2E')
    end

    # ---------------------------------------------------------------------

    def find_query ts
      res = time_query(ts)
      res = res.merge(scope_query) if @scope.present?
      res
    end

    def scope_query
      { s: @scope }
    end

    def time_query ts
      date = Date.today
      case ts
      when :ym then { y: date.year, m: date.month, d: nil }
      when :ymd then { y: date.year, m: date.month, d: date.day }
      end
    end

    private # =============================================================
    
    def browser
      return unless @user_agent_string.present?
      @browser ||= Browser.new(@user_agent_string)
    end

    def referer
      return unless @referer_string.present?
      @referer ||= Referer.new(@referer_string)
    end

  end
end
