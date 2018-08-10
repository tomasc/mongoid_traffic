# Mongoid Traffic

[![Build Status](https://travis-ci.org/tomasc/mongoid_traffic.svg)](https://travis-ci.org/tomasc/mongoid_traffic) [![Gem Version](https://badge.fury.io/rb/mongoid_traffic.svg)](http://badge.fury.io/rb/mongoid_traffic) [![Coverage Status](https://img.shields.io/coveralls/tomasc/mongoid_traffic.svg)](https://coveralls.io/r/tomasc/mongoid_traffic)

Aggregated traffic logs stored in MongoDB. Fast and efficient logging via atomic updates of nested hashes in small number of MongoDB documents, semi-fast retrieveal and aggregation.

## Installation

Add this line to your application's Gemfile:

```ruby
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

Setup your class for storing the log:

```ruby
class MyLog
	include Mongoid::Document
	include MongoidTraffic::Log
end
```

Log your traffic like this:

```ruby
MongoidTraffic::Logger.log(MyLog)
```

Or, if you prefer, directly on the `MyLog` class:

```ruby
MyLog.log
```

This will (by default) create four `MyLog` documents: each with `:df(date_from)` and `:dt(date_to)` fields specifying yearly, monthly, weekly and daily log. Each log has an `:access_count` attribute incremented with subsequent `.log` calls.

### Optional arguments

#### Time scope:

By default, the `.log` method creates/updates a document with aggregations for year, month, week and day. Subset of those  can be specified as:

```ruby
MyLog.log(time_scope: %i[day])
```

The available options are: `%i[year month week day]`

#### Scope:

```ruby
MyLog.log(scope: '/pages/123')
MyLog.log(scope: '/pages/456')
```

Allows to create several logs for different scopes (for example URLs). Ie.

```ruby
{ _id: …, df(date_from): …, dt(date_to): …, ac(access_count): 3, s(scope): '/pages/123' }
{ _id: …, df(date_from): …, dt(date_to): …, ac(access_count): 1, s(scope): '/pages/456' }
```

#### Arbitrary counter:

It is possible to count any number of arbitrary additional values. For example, to count unique country etc.

First, specify the additional counter in the log model (prefer short aliased field names):

```ruby
class MyLog
	include Mongoid::Document
	include MongoidTraffic::Log

	additional_counter :c, as: :country
end
```

Track access by country as:

```ruby
MyLog.log(country: 'CZ')
MyLog.log(country: 'NL')
```

Which will create Hash with counts per country:

```ruby
{ _id: …, df(date_from): …, dt(date_to): …, ac(access_count): 3, c(country): { 'CZ' => 1, 'NL' => 1 } }
```

You can take advantage of the fact, that the underlying queries support dot-notation, and track on deeply nested hashes. For example, should you want to track access per browser:

```ruby
class MyLog
	include Mongoid::Document
	include MongoidTraffic::Log

	additional_counter :b, as: :browser
end
```

Then track access by browser as:

```ruby
MyLog.log(browser: "Mac.Safari.8") # log access by Mac Safari 8
MyLog.log(browser: "Mac.Safari.7%2E1") # log access by Mac Safari 7.1
```

Which will create following log document:

```ruby
{ _id: …, df(date_from): …, dt(date_to): …, ac(access_count): 3, c(country): { 'Mac' => { 'Safari' => { '8' => 1, '7%2E1' => 1 } } } }
```

Please note all `.` not intended to denote nesting need to be escaped (here as `%2E`).

## Accessing the log

The log can be accessed using a combination of Mongoid Criteria and aggregation methods.

### Criteria

The following time based criteria are predefined as Mongoid scopes:

* `.day(date)`
* `.week(week, year)`
* `.month(month, year)`
* `.year(year)`
* `.for_dates(date_from, date_to)`

To select by log type:

* `.daily`
* `.weekly`
* `.monthly`
* `.yearly`

To narrow down by scope:

* `.scoped_to(scope)`

### Aggregation method

* `.aggregate_on(:access_count)`
* `.aggregate_on(ARBITRARY_COUNTER)`

Behind the scenes, this method will take all documents returned by your criteria and combines the values of the specified field (in case of `:access_count` it is simple sum of the values, in other cases it is sum of nested hashes).

### Examples

#### Time

```ruby
MyLog.day(Date.today)
```

Eventually by date range (when using the `.for_dates` scope please make sure to specify which log type you wish to access):

```ruby
MyLog.daily.for_dates(Date.yesterday, Date.today)
```

#### Scope

```ruby
MyLog.day(Date.today).scoped_to('/pages/123')
```

This order of scoping (date, scope) is important for performance reasons so that the queries take advantage of Mongoid collection index.

#### Aggregations

On access count:

```ruby
MyLog.day(Date.today).scoped_to('/pages/123').aggregate_on(:access_count) # => 1
```

The scope query accepts regular expressions, which allows for aggregations on specific parts of your site. For example should you want to query for all pages that have path beginning with '/blog':

```ruby
MyLog.month(8, 2014).scoped_to(/\A\/blog/).aggregate_on(:access_count) # => 1
```

On additional counter:

```ruby
MyLog.day(Date.today).scoped_to('/pages/123').aggregate_on(:country) # => { 'CZ' => 1, 'NL' => 1 }
```

#### Pluck

For plotting charts you might make use of standard `:pluck`:

```ruby
MyLog.daily.for_dates(Date.today - 1.week, Date.today).pluck(:date_from, :access_count) # => returns array of dates and counts per day
```





#### User-Agent:

```ruby
MyLog.log(user_agent: user_agent_string)
```

Logs platform-browser-version access count:

```ruby
{ "Macintosh" => { "Safari" => { "8%2E0" => 1, "7%2E1" => 2 } } }
```

Please note the keys are escaped. You might want to unescape them using for example `CGI::unescape`.

#### Referer:

```ruby
MyLog.log(referer: http_referer_string)
```

Logs referer access count:

```ruby
{ "http%3A%2F%2Fwww%2Egoogle%2Ecom" => 1 }
```

Please note the keys are escaped. You might want to unescape them using for example `CGI::unescape`.

If the referer is included in the [bot list](http://www.user-agents.org/allagents.xml) the log will not be created.

#### Country (via IP address):

```ruby
MyLog.log(ip_address: '123.123.123.123')
```

Logs access count by country code 2:

```ruby
{ "CZ" => 100, "DE" => 1 }
```

Uses the [GeoIP](https://github.com/cjheath/geoip) library to infer country_code from IP address.

You can use the [countries gem](https://github.com/hexorx/countries) to convert the country code to country name etc.

#### Unique id:

```ruby
MyLog.log(unique_id: unique_id_string)
```

Logs access count by id:

```ruby
{ "0123456789" => 100, "ABCDEFGHIJ" => 1 }
```

Typically you would pass it something like `session_id` to track unique visitors.

## Rails

In case of Rails, you can use the `.after_action` macro with the `#log_traffic` helper method in your controllers:

```ruby
class MyController < ApplicationController
	after_action -> { log_traffic(MyLog) }, only: [:show]
end
```

The method automatically infers most of the options from the controller `request` method (User-Agent, Referer, IP address) and unique id from the Rails session.

Additionally the `:log_scoped_traffic` method adds a scope by the current request path (`/pages/123`):

```ruby
class MyController < ApplicationController
	after_action -> { log_scoped_traffic(MyLog) }, only: [:show]
end
```

You can override this behavior with custom scope like this:

```ruby
class MyController < ApplicationController
	after_action -> { log_scoped_traffic(MyLog, scope: 'my-scope-comes-here') }, only: [:show]
end
```

It might be good idea to use both methods in order to log access to the whole site as well as access to individual pages:

```ruby
class MyController < ApplicationController
	after_action -> { log_traffic(MyLog) }, only: [:show]
	after_action -> { log_scoped_traffic(MyLog) }, only: [:show]
end
```


## Further reading

Based on the approach described by John Nunemaker [here](http://www.railstips.org/blog/archives/2011/06/28/counters-everywhere/) and [here](http://www.railstips.org/blog/archives/2011/07/31/counters-everywhere-part-2/).

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_traffic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
