require 'uri'
require 'useragent'

# require_relative './log'
# require_relative './logger/bots'
# require_relative './logger/browser'
# require_relative './logger/geo_ip'
# require_relative './logger/referer'

module MongoidTraffic
  class Logger
    attr_accessor :additonal_counters
    attr_accessor :log_cls
    attr_accessor :time_scope
    attr_accessor :scope

    def self.log(log_cls, *args)
      new(log_cls, *args).log
    end

    def initialize(log_cls, options = {})
      @log_cls = log_cls
      @time_scope = options.fetch(:time_scope, TIME_SCOPE_OPTIONS.keys)
      @scope = options.fetch(:scope, nil)
      @additonal_counters = options.except(*%i[time_scope scope])

      raise "Invalid time scope definition: #{time_scope}" unless time_scope.all? { |ts| TIME_SCOPE_OPTIONS.keys.include?(ts) }

      # @ip_address = ip_address
      # @referer_string = referer
      # @unique_id = unique_id
      # @user_agent_string = user_agent
    end

    def log
      # return if Bots.is_a_bot?(@referer_string)

      time_scope.each do |ts|
        log_cls.collection
               .find(find_query(ts))
               .update_many(upsert_query(ts), upsert: true)
      end
    end

    private

    def find_query(ts)
      time_query(ts).merge(scope_query)
    end

    def scope_query
      return {} unless scope
      { s: scope }
    end

    def upsert_query(time_scope)
      ts = TIME_SCOPE_OPTIONS[time_scope]

      {
        '$inc' => access_count_query.merge(additonal_counters_query),
        '$set' => { ts: ts, uat: Time.now }
      }
    end

    def access_count_query
      { ac: 1 }
    end

    def additonal_counters_query
      Array(additonal_counters).each_with_object({}) do |(name, value), res|
        next unless field = find_field(name)
        res["#{field.name}.#{value}"] = 1
      end
    end

    # def browser_query
    #   return {} unless browser.present?
    #   browser_path = [browser.platform, browser.name, browser.version].map { |s| escape_key(s) }.join('.')
    #   { "b.#{browser_path}" => 1 }
    # end
    #
    # def country_query
    #   return {} unless @ip_address.present?
    #   return {} unless country_code2 = GeoIp.country_code2(@ip_address)
    #   country_code_key = escape_key(country_code2)
    #   { "c.#{country_code_key}" => 1 }
    # end
    #
    # def referer_query
    #   return {} unless referer.present?
    #   referer_key = escape_key(referer.to_s)
    #   { "r.#{referer_key}" => 1 }
    # end
    #
    # def unique_id_query
    #   return {} unless @unique_id.present?
    #   unique_id_key = escape_key(@unique_id.to_s)
    #   { "u.#{unique_id_key}" => 1 }
    # end

    # def escape_key(key)
    #   CGI.escape(key).gsub('.', '%2E')
    # end

    def find_field(name)
      log_cls.fields.detect do |field_name, field|
        field_name == name.to_s || field.options[:as].to_s == name.to_s
      end.try(:last)
    end

    def time_query(ts)
      date = Date.today

      case ts
      when :day then { df: date, dt: date }
      else { df: date.send("at_beginning_of_#{ts}"), dt: date.send("at_end_of_#{ts}") }
      end
    end

    # private
    #
    # def browser
    #   return unless @user_agent_string.present?
    #   @browser ||= Browser.new(@user_agent_string)
    # end
    #
    # def referer
    #   return unless @referer_string.present?
    #   @referer ||= Referer.new(@referer_string)
    # end
  end
end
