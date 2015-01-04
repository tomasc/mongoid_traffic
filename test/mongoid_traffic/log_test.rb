require 'test_helper'

require_relative '../../lib/mongoid_traffic/log'

module MongoidTraffic
  describe 'Log' do
    subject { MyLog.new }

    describe 'fields' do
      it 'has :scope' do
        subject.must_respond_to :scope
      end
      it 'has :access_count' do
        subject.must_respond_to :access_count
      end
      it 'has :browsers' do
        subject.must_respond_to :browsers
        subject.browsers.must_be_kind_of Hash
      end
      it 'has :referers' do
        subject.must_respond_to :referers
        subject.referers.must_be_kind_of Hash
      end
      it 'has :countries' do
        subject.must_respond_to :countries
        subject.countries.must_be_kind_of Hash
      end
      it 'has :unique_ids' do
        subject.must_respond_to :unique_ids
        subject.unique_ids.must_be_kind_of Hash
      end
      it 'has :updated_at' do
        subject.must_respond_to :updated_at
      end
    end

    describe 'scopes' do
      it 'has :default_scope that assumes no :scope' do
        MyLog.criteria.selector.fetch('s').must_be_nil
      end

      it('has :for_dates') { MyLog.must_respond_to :for_dates }
      it('has :yearly') { MyLog.must_respond_to :yearly }
      it('has :monthly') { MyLog.must_respond_to :monthly }
      it('has :weekly') { MyLog.must_respond_to :weekly }
      it('has :daily') { MyLog.must_respond_to :daily }
      it('has :scoped_to') { MyLog.must_respond_to :scoped_to }
    end

    describe '.aggregate_on' do
      let(:log_1) { MyLog.new(date_from: Date.today, date_to: Date.today) }
      let(:log_2) { MyLog.new(date_from: Date.tomorrow, date_to: Date.tomorrow) }
      
      describe '.aggregate_on(:access_count)' do
        before do
          log_1.tap{ |l| l.access_count = 1 }.save
          log_2.tap{ |l| l.access_count = 2 }.save
        end

        it 'sums the access_counts' do
          MyLog.aggregate_on(:access_count).must_equal 3
        end
      end

      describe '.aggregate_on(:browsers)' do
        # not the key names have been abbreviated
        before do
          log_1.tap do |l| 
            l.browsers = {
              "Mac" => {
                "Saf" => { "8" => 1 } 
              }, 
              "Win" => { 
                "Saf" => { "7" => 5 } 
              }
            }
          end.save
          
          log_2.tap do |l| 
            l.browsers = { 
              "Mac" => { 
                "Saf" => { "8" => 10, "7" => 100 }, 
                "Chr" => { "3" => 5 } 
              }, 
              "Win" => { 
                "Saf" => { "7" => 100 }, 
                "IE" => { "10" => 1 } 
              } 
            }
          end.save
        end

        it 'sums the browsers' do
          MyLog.aggregate_on(:browsers).must_equal({
            "Mac" => { 
              "Saf" => { "8" => 11, "7" => 100 }, 
              "Chr" => { "3" => 5 } 
            }, 
            "Win" => { 
              "Saf" => { "7" => 105 }, 
              "IE" => { "10" => 1 } 
            }
          })
        end
      end

      describe '.aggregate_on(:referers)' do
        before do
          log_1.tap{ |l| l.referers = { 'google' => 100, 'apple' => 1000 } }.save
          log_2.tap{ |l| l.referers = { 'google' => 10, 'apple' => 100, 'ms' => 1 } }.save
        end

        it 'sums the referers' do
          MyLog.aggregate_on(:referers).must_equal({ 'google' => 110, 'apple' => 1100, 'ms' => 1 })
        end
      end

      describe '.aggregate_on(:countries)' do
        before do
          log_1.tap{ |l| l.countries = { 'CZ' => 100 } }.save
          log_2.tap{ |l| l.countries = { 'DE' => 10 } }.save
        end

        it 'sums the countries' do
          MyLog.aggregate_on(:countries).must_equal({ 'CZ' => 100, 'DE' => 10 })
        end
      end

      describe '.aggregate_on(:unique_ids)' do
        before do
          log_1.tap{ |l| l.unique_ids = { '01234' => 100, '56789' => 100 } }.save
          log_2.tap{ |l| l.unique_ids = { '56789' => 100 } }.save
        end

        it 'sums the unique_ids' do
          MyLog.aggregate_on(:unique_ids).must_equal({ '01234' => 100, '56789' => 200 })
        end
      end

      describe '.sum(:unique_ids)' do
        before do
          log_1.tap{ |l| l.unique_ids = { '01234' => 100, '56789' => 100 } }.save
          log_2.tap{ |l| l.unique_ids = { '56789' => 100, 'ABCDE' => 1 } }.save
        end

        it 'sums the unique_ids' do
          MyLog.sum(:unique_ids).must_equal 3
        end
      end
    end

  end
end