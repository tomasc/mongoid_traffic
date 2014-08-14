# Mongoid Traffic

[![Build Status](https://travis-ci.org/tomasc/mongoid_traffic.svg)](https://travis-ci.org/tomasc/mongoid_traffic) [![Gem Version](https://badge.fury.io/rb/mongoid_traffic.svg)](http://badge.fury.io/rb/mongoid_traffic) [![Coverage Status](https://img.shields.io/coveralls/tomasc/mongoid_traffic.svg)](https://coveralls.io/r/tomasc/mongoid_traffic)

Aggregated traffic logs stored in MongoDB. Fast and efficient logging via atomic updates of nested hashes in small number of MongoDB documents, semi-fast retrieveal and aggregation.

## Installation

Add this line to your application's Gemfile:

```Ruby
gem 'mongoid_traffic'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install mongoid_traffic
```

## Usage

Log your traffic like this:

```Ruby
MongoidTraffic::Logger.log
```

This will (by default) create two `MongoidTraffic::Log` documents: first with `:df(date_from)` and `:dt(date_to)` fields specifying monthly log, second with dates specifying daily log. Each log has an `:access_count` attribute that is incremented with subsequent `.log` calls.

### Optional arguments

#### Time scope:

By default, the `.log` method creates/updates a document with aggregations for month and a document with aggregations for a day. You can however customize this behaviour like this:

```Ruby
MongoidTraffic::Logger.log(time_scope: %i(month week day))
```

The available options are: `%(year month week day)`

#### Scope:

```Ruby
MongoidTraffic::Logger.log(scope: '/pages/123')
```

Allows to create several logs for different scopes of your application (typically URLs).

#### User-Agent:

```Ruby
MongoidTraffic::Logger.log(user_agent: user_agent_string)
```

Logs platform-browser-version access count:

```Ruby
{ "Macintosh" => { "Safari" => { "8%2E0" => 1, "7%2E1" => 2 } } }
```

Please note the keys are escaped. You might want to unescape them using for example `CGI::unescape`.

#### Referer:

```Ruby
MongoidTraffic::Logger.log(referer: http_referer_string)
```

Logs referer access count:

```Ruby
{ "http%3A%2F%2Fwww%2Egoogle%2Ecom" => 1 }
```

Please note the keys are escaped. You might want to unescape them using for example `CGI::unescape`.

If the referer is included in the [bot list](http://www.user-agents.org/allagents.xml) the log will not be created.

#### Country (via IP address):

```Ruby
MongoidTraffic::Logger.log(ip_address: '123.123.123.123')
```

Logs access count by country code 2:

```Ruby
{ "CZ" => 100, "DE" => 1 }
```

Uses the [GeoIP](https://github.com/cjheath/geoip) library to infer country_code from IP address.

You might can use for example the [countries gem](https://github.com/hexorx/countries) to convert the country code to country name etc.

#### Unique id:

```Ruby
MongoidTraffic::Logger.log(unique_id: unique_id_string)
```

Logs access count by id:

```Ruby
{ "0123456789" => 100, "ABCDEFGHIJ" => 1 }
```

Typically you would pass it something like `session_id` to track unique visitors.

## Rails

In case of Rails, you can use the `.after_action` macro with the `#log_traffic` helper method in your controllers:

```Ruby
class MyController < ApplicationController
	after_action :log_traffic, only: [:show]
end
```

The method automatically infers most of the options from the controller `request` method (User-Agent, Referer, IP address) and unique id from the Rails session.

Additionally the `:log_scoped_traffic` method adds a scope by the current request path (`/pages/123`):

```Ruby
class MyController < ApplicationController
	after_action :log_scoped_traffic, only: [:show]
end
```

You can override this behavior with custom scope like this:

```Ruby
class MyController < ApplicationController
	after_action :log_scoped_traffic, only: [:show]

	private
	
	def log_scoped_traffic
		super scope: 'my-scope-comes-here'
	end
end
```

It might be good idea to use both methods in order to log access to the whole site as well as access to individual pages:

```Ruby
class MyController < ApplicationController
	after_action :log_traffic, only: [:show]
	after_action :log_scoped_traffic, only: [:show]
end
```

## Accessing the log

The log is accessed with a combination of Mongoid Criteria and aggregation methods. 

### Criteria

The following time based criteria are predefined as Mongoid scopes:

* `.yearly(year)`
* `.monthly(month, year)`
* `.weekly(week, year)`
* `.daily(date)`

To narrow down by scope:

* `.for_scope(scope)`

### Aggregation method

* `.aggregate_on(:access_count)`
* `.aggregate_on(:user_agent)`
* `.aggregate_on(:referer)`
* `.aggregate_on(:country)`
* `.aggregate_on(:unique_id)`

Behind the scenes, this method will take all documents returned by your criteria and combines the values of the specified field (in case of `:access_count` it is simple sum of the values, in other cases it is sum of nested hashes).

### Examples

Typically you first query by time:

```Ruby
Mongoid::TrafficLog.daily(Date.today)
```

And eventually by scope:

```Ruby
Mongoid::TrafficLog.daily(Date.today).for_scope('/pages/123')
```

Followed by an aggregation. For example on access count:

```Ruby
Mongoid::TrafficLog.daily(Date.today).for_scope('/pages/123').aggregate_on(:access_count)
```

The scope query accepts regular expressions, which allows for aggregations on specific parts of your site. For example should you want to query for all pages that have path beginning with '/blog':

```Ruby
Mongoid::TrafficLog.monthly(8, 2014).for_scope(/\A\/blog/).aggregate_on(:country)
```

## Further reading

Based on the approach described by John Nunemaker [here](http://www.railstips.org/blog/archives/2011/06/28/counters-everywhere/) and [here](http://www.railstips.org/blog/archives/2011/07/31/counters-everywhere-part-2/).

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_traffic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
