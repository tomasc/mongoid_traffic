require 'test_helper'

describe MongoidTraffic::Log do
  subject { MyLog.new }

  describe 'default fields' do
    it { subject.must_respond_to :date_from }
    it { subject.must_respond_to :date_to }
    it { subject.must_respond_to :time_scope }
    it { subject.must_respond_to :access_count }
    it { subject.must_respond_to :scope }
    it { subject.must_respond_to :updated_at }
  end

  describe 'scopes' do
    it { MyLog.must_respond_to :for_dates }
    it { MyLog.must_respond_to :year }
    it { MyLog.must_respond_to :month }
    it { MyLog.must_respond_to :week }
    it { MyLog.must_respond_to :day }

    it { MyLog.must_respond_to :scoped_to }
  end

  describe '.aggregate_on' do
    let(:log_1) { MyLog.new(date_from: Date.today, date_to: Date.today, time_scope: MongoidTraffic::TIME_SCOPE_OPTIONS[:day]) }
    let(:log_2) { MyLog.new(date_from: Date.tomorrow, date_to: Date.tomorrow, time_scope: MongoidTraffic::TIME_SCOPE_OPTIONS[:day]) }

    describe 'access_count' do
      before do
        log_1.tap { |l| l.access_count = 1 }.save
        log_2.tap { |l| l.access_count = 2 }.save
      end

      it { MyLog.aggregate_on(:access_count).must_equal 3 }
      it { MyLog.day(Date.today).aggregate_on(:access_count).must_equal 1 }
      it { MyLog.day(Date.tomorrow).aggregate_on(:access_count).must_equal 2 }
    end

    describe 'access_count across scopes' do
      let(:scope_1) { 'ABC' }
      let(:scope_2) { 'DEF' }

      before do
        log_1.tap { |l| l.access_count = 1; l.scope = scope_1 }.save
        log_2.tap { |l| l.access_count = 2; l.scope = scope_2 }.save
      end

      it { MyLog.aggregate_on(:access_count).must_equal 3 }
      it { MyLog.scoped_to(scope_1).aggregate_on(:access_count).must_equal 1 }
      it { MyLog.scoped_to(scope_2).aggregate_on(:access_count).must_equal 2 }
    end

    describe 'arbitrary counter' do
      let(:country_1) { 'CZ' }
      let(:country_2) { 'NL' }

      before do
        log_1.tap { |l| l.country = { country_1 => 1, country_2 => 2 } }.save
        log_2.tap { |l| l.country = { country_1 => 2, country_2 => 0 } }.save
      end

      it { MyLog.aggregate_on(:country).must_equal(country_1 => 3, country_2 => 2) }
    end

    describe 'nested arbitrary counter' do
      let(:browser_1) { { 'Mac' => { 'Safari' => { '8' => 1 } } } }
      let(:browser_2) { { 'Mac' => { 'Safari' => { '8' => 1, '7%2E1' => 1 } } } }

      before do
        log_1.tap { |l| l.browser = browser_1 }.save
        log_2.tap { |l| l.browser = browser_2 }.save
      end

      it { MyLog.aggregate_on(:browser).must_equal('Mac' => { 'Safari' => { '8' => 2, '7%2E1' => 1 } }) }
    end

    describe 'aggregate on date range' do
      let(:log_3) { MyLog.new(date_from: Date.tomorrow + 1.day, date_to: Date.tomorrow + 1.day, time_scope: MongoidTraffic::TIME_SCOPE_OPTIONS[:day]) }

      before do
        log_1.tap { |l| l.access_count = 1 }.save
        log_2.tap { |l| l.access_count = 2 }.save
        log_3.tap { |l| l.access_count = 3 }.save
      end

      it { MyLog.aggregate_on(:access_count).must_equal 6 }
      it { MyLog.for_dates(Date.today, Date.tomorrow).aggregate_on(:access_count).must_equal 3 }
    end




    # describe '.aggregate_on(:browsers)' do
    #   # not the key names have been abbreviated
    #   before do
    #     log_1.tap do |l|
    #       l.browsers = {
    #         'Mac' => {
    #           'Saf' => { '8' => 1 }
    #         },
    #         'Win' => {
    #           'Saf' => { '7' => 5 }
    #         }
    #       }
    #     end.save
    #
    #     log_2.tap do |l|
    #       l.browsers = {
    #         'Mac' => {
    #           'Saf' => { '8' => 10, '7' => 100 },
    #           'Chr' => { '3' => 5 }
    #         },
    #         'Win' => {
    #           'Saf' => { '7' => 100 },
    #           'IE' => { '10' => 1 }
    #         }
    #       }
    #     end.save
    #   end
    #
    #   it 'sums the browsers' do
    #     MyLog.aggregate_on(:browsers).must_equal('Mac' => { 'Saf' => { '8' => 11, '7' => 100 }, 'Chr' => { '3' => 5 } }, 'Win' => { 'Saf' => { '7' => 105 }, 'IE' => { '10' => 1 } })
    #   end
    # end

    # describe '.aggregate_on(:referers)' do
    #   before do
    #     log_1.tap { |l| l.referers = { 'google' => 100, 'apple' => 1000 } }.save
    #     log_2.tap { |l| l.referers = { 'google' => 10, 'apple' => 100, 'ms' => 1 } }.save
    #   end
    #
    #   it 'sums the referers' do
    #     MyLog.aggregate_on(:referers).must_equal('google' => 110, 'apple' => 1100, 'ms' => 1)
    #   end
    # end

    # describe '.aggregate_on(:countries)' do
    #   before do
    #     log_1.tap { |l| l.countries = { 'CZ' => 100 } }.save
    #     log_2.tap { |l| l.countries = { 'DE' => 10 } }.save
    #   end
    #
    #   it 'sums the countries' do
    #     MyLog.aggregate_on(:countries).must_equal('CZ' => 100, 'DE' => 10)
    #   end
    # end

    # describe '.aggregate_on(:unique_ids)' do
    #   before do
    #     log_1.tap { |l| l.unique_ids = { '01234' => 100, '56789' => 100 } }.save
    #     log_2.tap { |l| l.unique_ids = { '56789' => 100 } }.save
    #   end
    #
    #   it 'sums the unique_ids' do
    #     MyLog.aggregate_on(:unique_ids).must_equal('01234' => 100, '56789' => 200)
    #   end
    # end

    # describe '.sum(:unique_ids)' do
    #   before do
    #     log_1.tap { |l| l.unique_ids = { '01234' => 100, '56789' => 100 } }.save
    #     log_2.tap { |l| l.unique_ids = { '56789' => 100, 'ABCDE' => 1 } }.save
    #   end
    #
    #   it 'sums the unique_ids' do
    #     MyLog.sum(:unique_ids).must_equal 3
    #   end
    # end
  end
end
