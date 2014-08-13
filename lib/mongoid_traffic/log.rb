module MongoidTraffic
  class Log

    include Mongoid::Document

    # ---------------------------------------------------------------------
    
    field :y, as: :year, type: Integer
    field :m, as: :month, type: Integer
    field :d, as: :day, type: Integer
    
    field :ac, as: :access_count, type: Integer
    field :b, as: :browsers, type: Hash, default: {}

    field :u, as: :updated_at, type: Time

    # ---------------------------------------------------------------------
    
    validates :year, presence: true
    validates :month, presence: true, inclusion: { in: 1..12 }
    validates :day, presence: true, inclusion: { in: 1..31 }

    # ---------------------------------------------------------------------
    
    scope :for_month, -> (year, month) { where(year: year, month: month, day: nil) }
    scope :for_date, -> date { where(year: date.year, month: date.month, day: date.day) }

    # =====================================================================
    
  end
end