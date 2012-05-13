# Frill

[![Build Status](https://secure.travis-ci.org/moonmaster9000/frill.png)](http://travis-ci.org/moonmaster9000/frill)

Simple decoration of objects for presentation. If you don't know what I'm talking
about, read up on decorators and their role in MVC.

Out of the box integration with Rails. 

## Installation

Throw this in your Gemfile:

```ruby
gem "frill"
```

## Usage

(For the purposes of this tutorial, I'm going to assume you're using
`frill` inside a Rails app. Checkout the `Usage outside Rails` section
below for information about how to use this outside of a Rails app.)

Imagine you're creating a web application that includes both a
JSON API and an HTML frontend, and you've decided to always present a
timestamp as YEAR/MONTH/DAY. Furthermore, when presented in HTML, you
always want your timestamps wrapped in `<b>` tags.

This is a perfect fit for the GoF decorator pattern.

Create a new TimestampFrill module in `app/frills/timestamp_frill`:

```ruby
module TimestampFrill
  include Frill

  def self.frill? object, context
    object.respond_to? :created_at
  end

  def created_at
    super.strftime "%Y/%m/%d"
  end
end
```

The first method `self.frill?` tells `Frill` what kind of objects this
decorator is applicable to. In our case, it's any object that responds
to `created_at`.

Next, let's create an `HtmlTimestampFrill` module:

```ruby
module HtmlTimestampFrill
  include Frill
  after TimestampFrill

  def self.frill? object, context
    object.respond_to?(:created_at) && context.request.format == "text/html"
  end

  def created_at
    helper.content_tag :b, super
  end
end
```

Two things to note: the `HtmlTimestampFrill` is only applicable to
objects that respond to `created_at` when presented in "html". Also, we
tell `Frill` to decorate after `TimestampFrill` is applied (so that
`super` in `created_at` returns our `TimestampFrill` response).

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

## Usage outside Rails

There are really just two integrations in a Rails app: the `frill` 
method inside of your controller, plus the ability to call 
`ActionView::Helper` methods inside of your module methods.

To kickoff the decoration of an object outside of a Rails application,
simply call `Frill.decorate`:

```ruby
Frill.decorate my_object, my_context
```

## License

MIT.
