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

## Basic Usage

Log your traffic like this:

	Mongoid::TrafficLogger.log('/pages/123', user_agent: user_agent_string, referer: referer_string)

Or, in case of Rails, you can use the `after_action` macro in your controllers:

	class MyController < ApplicationController
		after_action :log_traffic, only: [:show]
	end

## Accessing the log

### Access count

The total number of views across all properties within a specific month can be accessed like this:

	Mongoid::TrafficLog.for_all_properties.for_month(Date.today).access_count

The total number of views per `property` per specific date like this:

	Mongoid::TrafficLog.for_property('/pages/123').for_date(Date.today).access_count

### User Agent

### Referer

## Classes

This gem consists of two basic classes: `MongoidTraffic::Logger` and `MongoidTraffic::Log`. The `Logger` takes care of upserting data in to the db using atomic updates, while the `Log` class is a `Mongoid::Document` class that wraps the records into neat models with scopes and helper methods for querying the log.

## Logging

To log traffic:

	Mongoid::TrafficLogger.log(property)

Where `property` might be for example path of tracked view: `/pages/123`

This will create/update the following Mongoid month in a year:

	MongoidTraffic::Log y(year): 2014, m(month): 8, d(day): nil, rid(property): nil, ac(access_count): 1
	MongoidTraffic::Log y(year): 2014, m(month): 8, d(day): nil, rid(property): /pages/123, ac(access_count): 1

And for for specific date:

	MongoidTraffic::Log y(year): 2014, m(month): 8, d(day): 13, rid(property): nil, ac(access_count): 1
	MongoidTraffic::Log y(year): 2014, m(month): 8, d(day): 13, rid(property): /pages/123, ac(access_count): 1

Always tracking access to a `property` as well as an access across all properties.

### User Agent

Optionally, you can pass 'User-Agent' header string to the logger:

	Mongoid::TrafficLogger.log(user_agent: user_agent_string)

### Referer

Optionally, you can pass 'User-Agent' header string to the logger:

	Mongoid::TrafficLogger.log(referer: http_referer_string)

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_traffic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
