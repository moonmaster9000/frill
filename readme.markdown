# Frill

[![Build Status](https://secure.travis-ci.org/moonmaster9000/frill.png)](http://travis-ci.org/moonmaster9000/frill)
[![Build Dependency Status](https://gemnasium.com/moonmaster9000/frill.png)](https://gemnasium.com/moonmaster9000/frill.png)

Simple decoration of objects for presentation. Out of the box integration with Rails.


## Installation

Throw this in your Gemfile:

```ruby
gem "frill"
```

Generate a frill:

```sh
$ rails g frill Timestamp --test-framework=rspec
      create  app/frills/timestamp_frill.rb
      invoke  rspec
      create    spec/frills/timestamp_frill_spec.rb
```

## Usage

(For the purposes of this tutorial, I'm going to assume you're using
`frill` inside a Rails app. Checkout the `Usage outside Rails` section
below if you're not using Rails.)

Imagine you're creating a web application that includes both a
JSON API and an HTML frontend, and you've decided to always present a
timestamp as YEAR/MONTH/DAY. Furthermore, when presented in HTML, you
always want your timestamps wrapped in `<b>` tags.

This is a perfect fit for the GoF decorator pattern. Start by generating a `Timestamp` frill:

```sh
$ rails g frill Timestamp --test-framework=rspec
      create  app/frills/timestamp_frill.rb
      invoke  rspec
      create    spec/frills/timestamp_frill_spec.rb
```

You can safely leave off the `--test-framework=rspec` portion if you've configured rspec as your default framework (or
if you're not using rspec at all).

Now open up `app/frills/timestamp_frill.rb` and format those timestamps:

```ruby
module TimestampFrill
  include Frill

  def self.frill? object, context
    object.respond_to?(:created_at) && object.respond_to?(:updated_at)
  end

  def created_at
    format_time super
  end

  def updated_at
    format_time super
  end

  private

  def format_time(t)
    t.strftime "%Y/%m/%d"
  end
end
```

The first method `self.frill?` tells `Frill` what kind of objects this
decorator is applicable to. In our case, it's any object that have timestamps.

Next, let's create an `HtmlTimestampFrill` module:

```sh
$ rails g frill HtmlTimestamp --test-framework=rspec
      create  app/frills/html_timestamp_frill.rb
      invoke  rspec
      create    spec/frills/html_timestamp_frill_spec.rb
```

```ruby
module HtmlTimestampFrill
  include Frill
  after TimestampFrill

  def self.frill? object, context
    object.respond_to?(:created_at) &&
    object.respond_to?(:updated_at) &&
    context.request.format.html?
  end

  def created_at
     format_time_for_html super
  end

  def updated_at
    format_time_for_html super
  end

  private
  def format_time_for_html t
    h.content_tag :b, t
  end
end
```

Two things to note: the `HtmlTimestampFrill` is only applicable to
objects that have timestamps _when presented in "html"_. Also, we
tell `Frill` to decorate `after` `TimestampFrill` is applied (so that
`super` in `created_at` returns our `TimestampFrill` response).

Note that you can also specify decoration dependencies with `before` instead of `after`.

Next, in our controller, we need to decorate our objects with frills:

```ruby
class PostsController < ApplicationController
  respond_to :json, :html

  def show
    @article = frill Article.find(params[:id])
    respond_with @article
  end
end
```

Notice that we've wrapped our article in a `frill`.

In your html view, you simply call `@article.created_at`:

```erb
<%= @article.created_at %>
```

The same goes for your JSON view.

### 'frill' decorates individual objects _and_ collections

The `frill` helper will decorate both collections and associations. You can use it both within your controller
and within your views.

For example, inside a controller: 

```ruby
class PostsController < ApplicationController
  def index
    @posts = frill Post.all
  end

  def show
    @post = frill Post.find(params[:id])
  end
end
```

Or, in a view:

```erb
<%= render frill(@post.comments) %>
```

## Usage outside Rails

There are really just two integrations in a Rails app: the `frill` 
method inside of your controller, plus the ability to call 
`ActionView::Helper` methods inside of your module methods.

To kickoff the decoration of an object outside of a Rails application,
simply call `Frill.decorate`:

```ruby
Frill.decorate my_object, my_context
```

## Contributors

* Ben Moss
* Nicholas Greenfield

## License

(The MIT License)

Copyright © 2012 Matt Parker

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
