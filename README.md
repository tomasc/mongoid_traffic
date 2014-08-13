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

## Usage

Create your a Log class:

	class MyLogger < Mongoid::TrafficLogger
	end

Log traffic like this:

	MyLogger.log

This will create/update the following Mongoid records:

	MongoidTraffic::Log y(year): 2014, m(month): 8, d(day): nil
	MongoidTraffic::Log y(year): 2014, m(month): 8, d(day): 13

## User Agent

Optionally, you can pass 'User-Agent' header string to the logger:

	MyLogger.log(user_agent: user_agent_string)

## Referer

Optionally, you can pass 'User-Agent' header string to the logger:

	MyLogger.log(referer: http_referer_string)

## Rails

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_traffic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
