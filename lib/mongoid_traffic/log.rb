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
    scope :daily, -> date { self.for_dates(date, date) }

    scope :for_scope, -> scope { where(scope: scope) }
    
  end
end