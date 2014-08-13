# Mongoid Traffic

[![Build Status](https://travis-ci.org/tomasc/mongoid_traffic.svg)](https://travis-ci.org/tomasc/mongoid_traffic) [![Gem Version](https://badge.fury.io/rb/mongoid_traffic.svg)](http://badge.fury.io/rb/mongoid_traffic) [![Coverage Status](https://img.shields.io/coveralls/tomasc/mongoid_traffic.svg)](https://coveralls.io/r/tomasc/mongoid_traffic)

Aggregated traffic logs stored in MongoDB. Based on the approach described by John Nunemaker [here](http://www.railstips.org/blog/archives/2011/06/28/counters-everywhere/) and [here](http://www.railstips.org/blog/archives/2011/07/31/counters-everywhere-part-2/).

## Installation

Add this line to your application's Gemfile:

	gem 'mongoid_traffic'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install mongoid_traffic

## Classes

This gem consists of two basic classes: `MongoidTraffic::Logger` and `MongoidTraffic::Log`. The `Logger` takes care of upserting data in to the db using atomic updates, while the `Log` class is a `Mongoid::Document` class that wraps the records into neat models with scopes and helper methods for querying the log.

## Logging

To log traffic:

	Mongoid::TrafficLogger.log(record_id)

Where `record_id` might be for example path of tracked view: `/pages/123`

This will create/update the following Mongoid records:

	MongoidTraffic::Log y(year): 2014, m(month): 8, d(day): nil, rid(record_id): nil, ac(access_count): 1
	MongoidTraffic::Log y(year): 2014, m(month): 8, d(day): nil, rid(record_id): /pages/123, ac(access_count): 1
	MongoidTraffic::Log y(year): 2014, m(month): 8, d(day): 13, rid(record_id): /pages/123, ac(access_count): 1

The first one is a cache of all access per whole Log (for example per whole site), the next two are logs per record_id per month and per day.

### User Agent

Optionally, you can pass 'User-Agent' header string to the logger:

	Mongoid::TrafficLogger.log(user_agent: user_agent_string)

### Referer

Optionally, you can pass 'User-Agent' header string to the logger:

	Mongoid::TrafficLogger.log(referer: http_referer_string)

### Rails

## Accessing the log

### Access count

The total number of views in a specific month can be accessed like this:

	Mongoid::TrafficLog.for_month(2014, 8).access_count

The total number of views per `record_id` like this:

	Mongoid::TrafficLog.for_record_id('/pages/123').for_month(2014, 8).access_count

### User Agent

### Referer

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_traffic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
