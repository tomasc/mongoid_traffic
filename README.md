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
Mongoid::TrafficLogger.log
```

### Optional arguments

#### Time scope:

By default, the `.log` method creates/updates a document with aggregations for month and a document with aggregations for a day. You can however customize this behaviour like this:

```Ruby
Mongoid::TrafficLogger.log(time_scope: %i(month week day))
```

The available options are: `%(year month week day hour)`

Your application might display daily stats for the last month, and then only aggregations per the previous months. In that case, you might want to regularly purge the no longer needed daily logs.

#### Scope:

```Ruby
Mongoid::TrafficLogger.log(scope: '/pages/123')
```

#### User-Agent:

```Ruby
Mongoid::TrafficLogger.log(user_agent: user_agent_string)
```

#### Referer:

```Ruby
Mongoid::TrafficLogger.log(referer: http_referer_string)
```

(If the referer is included in the [bot list](http://www.user-agents.org/allagents.xml) the log will not be created.)

#### Country (via IP address):

```Ruby
Mongoid::TrafficLogger.log(ip_address: '123.123.123.123')
```

This will use the [GeoIP](https://github.com/cjheath/geoip) library to log country.

#### Unique id:

```Ruby
Mongoid::TrafficLogger.log(unique_id: unique_id_string)
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
Mongoid::TrafficLog.for_date(Date.today)
```

And eventually by scope:

```Ruby
Mongoid::TrafficLog.for_date(Date.today).for_scope('/pages/123')
```

Followed by an aggregation. For example on access count:

```Ruby
Mongoid::TrafficLog.for_date(Date.today).for_scope('/pages/123').aggregate_on(:access_count)
```

The scope query accepts regular expressions, which allows for aggregations on specific parts of your site. For exmaple should you want to query for all pages that have path beginning with '/blog':

```Ruby
Mongoid::TrafficLog.for_year(2014).for_month(8).for_scope(/\A\/blog/).aggregate_on(:country)
```

## Credits & further reading

Based on the approach described by John Nunemaker [here](http://www.railstips.org/blog/archives/2011/06/28/counters-everywhere/) and [here](http://www.railstips.org/blog/archives/2011/07/31/counters-everywhere-part-2/).

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_traffic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
