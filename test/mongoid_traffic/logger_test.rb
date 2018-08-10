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

      before { MongoidTraffic::Logger.log(MyLog, scope: scope, time_scope: %i[day]) }

      it { daily_log.scoped_to(scope).first.access_count.must_equal 1 }
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









    # let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/538.46 (KHTML, like Gecko) Version/8.0 Safari/538.46' }
    # let(:referer) { 'http://www.google.com' }
    #
    # let(:unique_id) { 'ABC' }

    # it { MyLog.first.access_count.must_equal 1 }
    # it { MyLog.first.updated_at.must_be :present? }

    # MyLog.scoped_to(scope).count.must_equal 2
    # it 'logs user_agent' do
    #   MyLog.first.browsers.fetch('Macintosh').fetch('Safari').fetch('8%2E0').must_equal 1
    # end
    # it 'logs referer' do
    #   MyLog.first.referers.fetch('http%3A%2F%2Fwww%2Egoogle%2Ecom').must_equal 1
    # end
    # it 'logs country' do
    #   MyLog.first.countries.fetch('DE').must_equal 1
    # end
    # it 'logs unique_id' do
    #   MyLog.first.unique_ids.fetch('ABC').must_equal 1
    # end

    # describe 'when referer a bot' do
    #   let(:referer) { 'Googlebot/Test ( http://www.googlebot.com/bot.html)' }
    #   it 'does not create log' do
    #     MyLog.exists?.must_equal false
    #   end
    # end
  end
end
