require 'uri'
require 'useragent'

require_relative './log'
require_relative './logger/bots'
require_relative './logger/browser'
require_relative './logger/geo_ip'
require_relative './logger/referer'

module MongoidTraffic
  class Logger

    TIME_SCOPE_OPTIONS = %i(year month week day)

    # ---------------------------------------------------------------------

    def self.log log_cls, *args
      new(log_cls, *args).log
    end

    # ---------------------------------------------------------------------

    def initialize log_cls, ip_address: nil, referer: nil, scope: nil, time_scope: %i(month day), unique_id: nil, user_agent: nil
      @log_cls = log_cls
      @ip_address = ip_address
      @referer_string = referer
      @scope = scope
      @time_scope = time_scope
      @unique_id = unique_id
      @user_agent_string = user_agent
    end

    def log
      return if Bots.is_a_bot?(@referer_string)
      raise "Invalid time scope definition: #{@time_scope}" unless @time_scope.all?{ |ts| TIME_SCOPE_OPTIONS.include?(ts) }

      @time_scope.each do |ts|
        @log_cls.collection.find( find_query(ts) ).update_many( upsert_query, upsert: true )
      end
    end

    # ---------------------------------------------------------------------

    def upsert_query
      {
        '$inc' => access_count_query.
          merge(browser_query).
          merge(country_query).
          merge(referer_query).
          merge(unique_id_query),
        '$set' => { uat: Time.now }
      }
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

    def country_query
      return {} unless @ip_address.present?
      return {} unless country_code2 = GeoIp.country_code2(@ip_address)
      country_code_key = escape_key(country_code2)
      { "c.#{country_code_key}" => 1 }
    end

    def referer_query
      return {} unless referer.present?
      referer_key = escape_key(referer.to_s)
      { "r.#{referer_key}" => 1 }
    end

    def unique_id_query
      return {} unless @unique_id.present?
      unique_id_key = escape_key(@unique_id.to_s)
      { "u.#{unique_id_key}" => 1 }
    end

    # ---------------------------------------------------------------------

    def escape_key key
      CGI::escape(key).gsub('.', '%2E')
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
      when :day then { df: date, dt: date }
      else { df: date.send("at_beginning_of_#{ts}"), dt: date.send("at_end_of_#{ts}") }
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
