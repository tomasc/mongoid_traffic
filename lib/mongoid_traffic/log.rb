module MongoidTraffic
  class Log

    include Mongoid::Document

    # ---------------------------------------------------------------------
    
    field :y, as: :year, type: Integer
    field :m, as: :month, type: Integer
    field :d, as: :day, type: Integer
    
    field :p, as: :property, type: String

    field :ac, as: :access_count, type: Integer
    field :b, as: :browsers, type: Hash, default: {}

    # ---------------------------------------------------------------------
    
    validates :year, presence: true
    validates :month, presence: true, inclusion: { in: 1..12 }
    validates :day, presence: true, inclusion: { in: 1..31 }

    # ---------------------------------------------------------------------
    
    scope :for_all_properties, -> { where(property: nil) }
    scope :for_property, -> (property) { where(property: property) }
    scope :for_month, -> (date) { where(year: date.year, month: date.month, day: nil) }
    scope :for_date, -> date { where(year: date.year, month: date.month, day: date.day) }

    # =====================================================================
    
  end
end