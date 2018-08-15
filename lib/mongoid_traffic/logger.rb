module MongoidTraffic
  class Logger
    attr_accessor :log_cls
    attr_accessor :selector
    attr_accessor :time_scope
    attr_accessor :additonal_counters

    def self.log(log_cls, *args)
      new(log_cls, *args).log
    end

    def initialize(log_cls, options = {})
      @log_cls = log_cls
      @selector = log_cls.criteria.selector
      @time_scope = options.fetch(:time_scope, TIME_SCOPE_OPTIONS.keys)
      @additonal_counters = options.except(:time_scope, :scope)

      raise "Invalid time scope definition: #{time_scope}" unless time_scope.all? { |ts| TIME_SCOPE_OPTIONS.key?(ts) }
    end

    def log
      time_scope.each do |ts|
        log_cls.collection
               .find(find_query(ts))
               .update_many(upsert_query(ts), upsert: true)
      end
    end

    private

    def find_query(ts)
      time_query(ts).merge(selector)
    end

    def upsert_query(time_scope)
      ts = TIME_SCOPE_OPTIONS[time_scope]

      { '$inc' => access_count_query.merge(additonal_counters_query),
        '$set' => { ts: ts, uat: Time.now } }
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
  end
end
