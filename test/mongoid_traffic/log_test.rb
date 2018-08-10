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
  end
end
