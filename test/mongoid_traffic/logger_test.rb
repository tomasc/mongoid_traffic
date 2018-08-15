require 'test_helper'

describe MongoidTraffic::Logger do
  let(:date) { Date.today }

  describe '.log' do
    let(:yearly_log) { MyLog.year(date.year) }
    let(:monthly_log) { MyLog.month(date.month, date.year) }
    let(:weekly_log) { MyLog.week(date.cweek, date.year) }
    let(:daily_log) { MyLog.day(date) }

    describe 'default' do
      before { MongoidTraffic::Logger.log(MyLog) }

      it { yearly_log.first.access_count.must_equal 1 }
      it { monthly_log.first.access_count.must_equal 1 }
      it { weekly_log.first.access_count.must_equal 1 }
      it { daily_log.first.access_count.must_equal 1 }
    end

    describe 'with time scope' do
      before { MongoidTraffic::Logger.log(MyLog, time_scope: %i[day]) }

      it { yearly_log.wont_be :exists? }
      it { monthly_log.wont_be :exists? }
      it { weekly_log.wont_be :exists? }
      it { daily_log.first.access_count.must_equal 1 }
    end

    describe 'with scope' do
      let(:scope) { 'my/path' }

      before { MyLog.with_my_scope(scope).log(time_scope: %i[day]) }

      it { daily_log.with_my_scope(scope).first.access_count.must_equal 1 }
    end

    describe 'with additional counters' do
      let(:country_1) { 'ABC' }
      let(:country_2) { 'DEF' }

      before do
        MongoidTraffic::Logger.log(MyLog, time_scope: %i[day])
        MongoidTraffic::Logger.log(MyLog, time_scope: %i[day], country: country_1)
        MongoidTraffic::Logger.log(MyLog, time_scope: %i[day], country: country_1)
        MongoidTraffic::Logger.log(MyLog, time_scope: %i[day], country: country_2)
      end

      it { daily_log.aggregate_on(:access_count).must_equal 4 }
      it { daily_log.aggregate_on(:country).must_equal(country_1 => 2, country_2 => 1) }
    end
  end
end
