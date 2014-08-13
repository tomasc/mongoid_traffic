# Mongoid Traffic

[![Build Status](https://travis-ci.org/tomasc/mongoid_traffic.svg)](https://travis-ci.org/tomasc/mongoid_traffic) [![Gem Version](https://badge.fury.io/rb/mongoid_traffic.svg)](http://badge.fury.io/rb/mongoid_traffic) [![Coverage Status](https://img.shields.io/coveralls/tomasc/mongoid_traffic.svg)](https://coveralls.io/r/tomasc/mongoid_traffic)

Aggregated traffic logs stored in MongoDB. Based on the approach described by John Nunemaker [here](http://www.railstips.org/blog/archives/2011/06/28/counters-everywhere/) and [here](http://www.railstips.org/blog/archives/2011/07/31/counters-everywhere-part-2/).

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

Or, in case of Rails, you can use the `.after_action` macro with the `#log_traffic` helper method in your controllers:

```Ruby
class MyController < ApplicationController
	after_action :log_traffic, only: [:show]
end
```

### Scope

You can scope the log using the (optional) `scope:` argument:

```Ruby
Mongoid::TrafficLogger.log(scope: '/pages/123')
```

Or, in case of Rails controller:

```Ruby
class MyController < ApplicationController
	after_action :log_scoped_traffic, only: [:show]
end
```

By default, the `:log_scoped_traffic` method scopes your log by the request path (for example '/pages/123'). You can override this behavior with custom scope like this:

```Ruby
class MyController < ApplicationController
	after_action :log_scoped_traffic, only: [:show]

	private
	
	def log_scoped_traffic
		super.log_scoped_traffic(scope: 'my-scope-comes-here')
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

### Access count

The total number of views within a specific month can be accessed like this:

```Ruby
Mongoid::TrafficLog.for_year(2014).for_month(8).access_count
```

The total number of views per scope per specific date like this:

```Ruby
Mongoid::TrafficLog.for_date(Date.today).access_count
```

### User Agent

Optionally, you can pass 'User-Agent' header string to the logger:

```Ruby
Mongoid::TrafficLogger.log(user_agent: user_agent_string)
```

### Referer

Optionally, you can pass 'User-Agent' header string to the logger:

```Ruby
Mongoid::TrafficLogger.log(referer: http_referer_string)
```

## Contributing

1. Fork it ( https://github.com/tomasc/mongoid_traffic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
