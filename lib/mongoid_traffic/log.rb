module MongoidTraffic
  class Log

    include Mongoid::Document

    # ---------------------------------------------------------------------
    
    field :y, as: :year, type: Integer
    field :m, as: :month, type: Integer
    field :d, as: :day, type: Integer
    
    field :s, as: :scope, type: String

    field :ac, as: :access_count, type: Integer
    field :b, as: :browsers, type: Hash, default: {}
    field :c, as: :countries, type: Hash, default: {}
    field :r, as: :referers, type: Hash, default: {}

    field :uat, as: :updated_at, type: Time

    # ---------------------------------------------------------------------
    
    validates :year, presence: true
    validates :month, presence: true, inclusion: { in: 1..12 }
    validates :day, presence: true, inclusion: { in: 1..31 }

    # ---------------------------------------------------------------------
    
    default_scope -> { where(scope: nil, year: Date.today.year, month: nil, day: nil) }

    scope :for_year, -> year { where(year: year) }
    scope :for_month, -> month { where(month: month) }
    scope :for_day, -> day { where(day: day) }
    scope :for_date, -> date { where(year: date.year, month: date.month, day: date.day) }

    scope :for_scope, -> scope { where(scope: scope) }
    
  end
end

# df
# dt
# time_scope: [y,m,w,d,h,m]