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

## Further reading

Based on the approach described by John Nunemaker [here](http://www.railstips.org/blog/archives/2011/06/28/counters-everywhere/) and [here](http://www.railstips.org/blog/archives/2011/07/31/counters-everywhere-part-2/).

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_traffic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
