# Mongoid Traffic

[![Build Status](https://travis-ci.org/tomasc/mongoid_traffic.svg)](https://travis-ci.org/tomasc/mongoid_traffic) [![Gem Version](https://badge.fury.io/rb/mongoid_traffic.svg)](http://badge.fury.io/rb/mongoid_traffic) [![Coverage Status](https://img.shields.io/coveralls/tomasc/mongoid_traffic.svg)](https://coveralls.io/r/tomasc/mongoid_traffic)

Aggregated traffic logs stored in MongoDB. 

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

Eventually the `:log_scoped_traffic` method which scopes the log by the current request path (`/pages/123`):

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

The following criteria are predefined as Mongoid scopes:

* `.for_year(year)`
* `.for_month(month)`
* `.for_day(day)`
* `.for_date(date)`
* `.for_scope(scope)`

### Aggregation method

* `.aggregate_on(:access_count)`
* `.aggregate_on(:user_agent)`
* `.aggregate_on(:referer)`
* `.aggregate_on(:country)`
* `.aggregate_on(:unique_id)`

Behind the scenes, this method will take all documents returned by your criteria and combines the values of the specified field (in case of `:access_count` it is simple sum of the values, in other cases it is sum of deeply nested hashes).

### Examples

When combined you can scope your queries by time:

```Ruby
Mongoid::TrafficLog.for_date(Date.today)
```

And scope:

```Ruby
Mongoid::TrafficLog.for_date(Date.today).for_scope('/pages/123')
```

And retrieve aggregated access count:

```Ruby
Mongoid::TrafficLog.for_date(Date.today).for_scope('/pages/123').aggregate_on(:access_count)
```

Or access count by country:

```Ruby
Mongoid::TrafficLog.for_date(Date.today).for_scope('/pages/123').aggregate_on(:country)
```

The scope query accepts regular expressions, which allows for aggregations on specific parts of your site. For exmaple should you want to query for all pages whose path starts with '/blog':

```Ruby
Mongoid::TrafficLog.for_year(2014).for_month(8).for_scope(/\A\/blog/).aggregate_on(:country)
```

## Credits

Based on the approach described by John Nunemaker [here](http://www.railstips.org/blog/archives/2011/06/28/counters-everywhere/) and [here](http://www.railstips.org/blog/archives/2011/07/31/counters-everywhere-part-2/).

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_traffic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
