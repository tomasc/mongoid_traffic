module MongoidTraffic
  class Log

    include Mongoid::Document

    # ---------------------------------------------------------------------
    
    field :s, as: :scope, type: String

    field :ac, as: :access_count, type: Integer
    field :b, as: :browsers, type: Hash, default: {}
    field :c, as: :countries, type: Hash, default: {}
    field :r, as: :referers, type: Hash, default: {}

    field :uat, as: :updated_at, type: Time

    # ---------------------------------------------------------------------
    
    field :df, as: :date_from, type: Date
    field :dt, as: :date_to, type: Date

    # ---------------------------------------------------------------------
    
    validates :date_from, presence: true
    validates :date_to, presence: true

    # ---------------------------------------------------------------------
    
    default_scope -> { where(scope: nil) }

    scope :for_dates, -> date_from, date_to { where(date_from: date_from, date_to: date_to) }

    scope :yearly, -> year { self.for_dates(Date.parse("01/01/#{year}"), Date.parse("01/01/#{year}").at_end_of_year) }
    scope :monthly, -> month, year { self.for_dates(Date.parse("01/#{month}/#{year}"), Date.parse("01/#{month}/#{year}").at_end_of_month) }
    scope :weekly, -> week, year { self.for_dates(Date.commercial(year, week), Date.commercial(year, week).at_end_of_week) }
    scope :daily, -> date { self.for_dates(date, date) }

    scope :scoped_to, -> scope { where(scope: scope) }
    
    # =====================================================================
    
    def self.aggregate_on att
      case find_field_by_name(att).type.to_s
      when 'Integer' then sum(att)
      when 'Hash' then sum_hash(att)
      end
    end


    private # =============================================================
    
    def self.find_field_by_name field_name
      return unless f = fields.detect{ |k,v| k == field_name.to_s or v.options[:as].to_s == field_name.to_s }
      f.last
    end

    def self.sum_hash field_name
      res = {}
      self.pluck(field_name).each do |h|
        merger = proc { |key, v1, v2| 
          if Hash === v1 && Hash === v2
            v1.merge(v2, &merger)
          elsif Hash === v2
            v2
          else
            v1.to_i + v2.to_i
          end
        }
        res = res.merge(h, &merger)
      end
      res
    end

  end
end