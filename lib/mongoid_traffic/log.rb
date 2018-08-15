module MongoidTraffic
  module Log
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        field :df, as: :date_from, type: Date
        field :dt, as: :date_to, type: Date
        field :ts, as: :time_scope, type: Integer

        field :ac, as: :access_count, type: Integer
        field :uat, as: :updated_at, type: Time

        validates :date_from, presence: true
        validates :date_to, presence: true

        scope :yearly, -> { where(ts: TIME_SCOPE_OPTIONS[:year]) }
        scope :monthly, -> { where(ts: TIME_SCOPE_OPTIONS[:month]) }
        scope :weekly, -> { where(ts: TIME_SCOPE_OPTIONS[:year]) }
        scope :daily, -> { where(ts: TIME_SCOPE_OPTIONS[:day]) }

        scope :for_dates, ->(date_from, date_to) { where(:date_from.lte => date_to, :date_to.gte => date_from) }
        scope :year, ->(year) { yearly.for_dates(Date.parse("01/01/#{year}"), Date.parse("01/01/#{year}").at_end_of_year) }
        scope :month, ->(month, year) { monthly.for_dates(Date.parse("01/#{month}/#{year}"), Date.parse("01/#{month}/#{year}").at_end_of_month) }
        scope :week, ->(week, year) { weekly.for_dates(Date.commercial(year, week), Date.commercial(year, week).at_end_of_week) }
        scope :day, ->(date) { daily.for_dates(date, date) }

        index time_scope: 1, date_from: 1, date_to: 1
      end
    end

    module ClassMethods
      def log(*args)
        MongoidTraffic::Logger.log(self, *args)
      end

      def additional_counter(name, as: nil)
        field name, as: as, type: Hash, default: {}
      end

      def aggregate_on(att)
        field = find_field(att)
        case field.type.to_s
        when 'Integer' then sum(field.name)
        when 'Hash' then sum_hash(field.name)
        end
      end

      private

      def find_field(name)
        fields.detect do |field_name, field|
          field_name == name.to_s || field.options[:as].to_s == name.to_s
        end.try(:last)
      end

      def sum_hash(field_name)
        pluck(field_name).inject({}) do |res, h|
          merger = proc do |_, v1, v2|
            if Hash === v1 && Hash === v2 then v1.merge(v2, &merger)
            elsif Hash === v2 then v2
            else v1.to_i + v2.to_i
            end
          end
          res = res.merge(h, &merger)
        end
      end
    end
  end
end
