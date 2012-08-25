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

## Refactoring timestamp helpers with decorators

Your product manager writes the following story for you: 

```cucumber
Feature: Consistent Timestamp Presentation
  As a user
  I want "created at" timestamps presented in a uniform way on the site
  So that I can easily discover the age of content on the site

  Scenario: Presenting timestamps
    When I navigate to a page that displays a created_at timestamp
    Then I should see that timestamp marked up as bold and formatted as follows: YYYY/MM/DD
```

You see this and roll your eyes. You're thinking about all of the places that you show `created_at` 
timestamps on the site. Regardless you roll up your sleeves and start by writing the following helper and partial:

```ruby
module ApplicationHelper
  def format_timestamp(t)
    render partial: "shared/timestamp", locals: { time: t.strftime "%Y/%m/%d" }
  end
end
```

```erb
<b><%=time%></b>
```

You then begin the tedious task of tracking down all of the places you render timestamps on the site and wrapping them with `format_timestamp` helper calls:

```erb
...
Written on <%=format_timestamp @article.created_at %>
```

You hate this approach.

1. It's tedious
1. It's procedural
1. Developers have to remember to manually wrap timestamps with your `format_timestamp` helper. Developers suck at remembering things like that. FACEPALM

After you deliver the story, your product owner says "Great! But what about the format of timestamps in the JSON api? Here's another story."

```cucumber
Feature: Consistent Timestamp Presentation in the API
  As an API consumer
  I want "created at" timestamps presented in the API in uniform way
  So that I can easily discover the age of data I consume

  Scenario: Presenting timestamps
    When I retrieve content with a "created_at" timestamp via the JSON API
    Then I should see that timestamp formatted as follows: YYYY/MM/DD
```

You attempt to salvage the helper, updating it with concerns for the JSON format:

```ruby
module ApplicationHelper
  def format_timestamp(t)
    time = t.strftime "%Y/%m/%d" 

    if request.format.html?
      render partial: "shared/timestamp", locals: { time: time }
    elsif request.format.json?
      time
    end
  end
end
```

And now you begin the tedious task of updating all of the JSON views with the helper:

```ruby
json.created_at format_timestamp(@article.created_at)
```

At this point, you're banging your head against a table.

### Enter Frill

Let's refactor this using the decorator pattern. First, revert all of your changes. Next, add the `frill` gem to your Gemfile, run `bundle`, then generate a frill: `rails g frill TimestampFrill`:

```ruby
module TimestampFrill
  include Frill

  def self.frill? object, context
    object.respond_to?(:created_at)
  end

  def created_at
    super.strftime "%Y/%m/%d"
  end
end
```

The `frill?` method tells `Frill` when to extend an object with this module. Then we redefine the `created_at` method, 
calling super and then formatting the date returned with `strftime`.

Simple enough. 

Next, generate another frill for presenting timestamps via HTML (`rails g frill HtmlTimestampFrill`):

```ruby
module HtmlTimestampFrill
  include Frill
  after TimestampFrill

  def self.frill? object, context
    object.respond_to?(:created_at) && context.request.format.html?
  end

  def created_at
     h.render partial: "shared/timestamp", locals: { time: super }
  end
end
```

There's two important things to note: 

1. This frill comes after `TimestampFrill`. That tells `Frill` that it should only attempt to extend an object with this module after attempting to extend it with `TimestampFrill`.
1. The `frill?` method only returns true if it's an HTML request, meaning this frill won't be extended onto objects for your JSON api.

Lastly, opt objects into frilling inside your controllers: 

```ruby
class ArticlesController < ApplicationController
  respond_to :json, :html

  def show
    @article = frill Article.find(params[:id])
    respond_with @article
  end
end
```

And that's it. You don't have to update any of your views. Why? When you call the `frill` method inside your controller and pass it an object (or a collection of objects), 
frill will attempt to extend the object with any applicable frills (i.e., frills that return `true` for the `frill?` method when passed the object and the request context).

That way, you can simply render your `created_at` attributes without any helpers, and they will automatically present themselves appropriately for their context (e.g., HTML v. JSON requests).

Note that if prefer, you can configure your controllers to automatically frill all objects for presentation by calling the `auto_frill` method inside your `ApplicationController`, instead of manually having to opt them it via the `frill` method:

```ruby
class ApplicationController < ActionController::Base
  auto_frill
end
```

Now, you could remove the `frill` from your `ArticlesController`:

```ruby
class ArticlesController < ApplicationController
  respond_to :json, :html

  def show
    @article = Article.find(params[:id])
    respond_with @article
  end
end
```

Now, any instance variables you create in your controllers will be automatically frilled before handed off to your views.

### 'frill' decorates individual objects _and_ collections

As I've hinted at, the `frill` helper will decorate both single objects and collections of objects. You can use it both within your controller
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
helper methods inside of your module methods.

To kickoff the decoration of an object outside of a Rails application,
simply call `Frill.decorate`:

```ruby
Frill.decorate my_object, my_context
```

## Contributors

* Ben Moss
* Nicholas Greenfield
