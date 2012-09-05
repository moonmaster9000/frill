# Frill

[![Build Status](https://secure.travis-ci.org/moonmaster9000/frill.png)](http://travis-ci.org/moonmaster9000/frill)
[![Build Dependency Status](https://gemnasium.com/moonmaster9000/frill.png)](https://gemnasium.com/moonmaster9000/frill.png)

Simple decoration of objects for presentation. Out of the box integration with Rails.


## Installation

Throw this in your Gemfile:

```ruby
gem "frill"
```

## In a nutshell

Decorate your objects for presentation. 

```sh
$ rails g frill FooFrill
```

Frills are just modules that decorate your objects with extra functionality. The `frill?` method on the module tells `Frill` when
to decorate an object with a module:

```ruby
module FooFrill
  def self.frill? object, context
    object.respond_to?(:foo)
  end

  def foo
    h.content_tag :b, "#{super} bar"
  end
end
```

The `h` method gives you access to all of the view helpers you would normally expect to use inside a view or a helper.
It's aliased to `helpers`, so feel free to use either.

Opt objects in your controllers into frill with the `frill` method:

```ruby
class FooController < ApplicationController
  def foo
    @foo = frill Foo.find(params[:id])
  end
end
```

Then just use the `foo` method on your Foo objects to get their decorated functionality:

```erb
Awesome foo page!

<%=@foo.foo%>
```

Instead of manually opting objects into decoration via the `frill` method, you can have all of your controller
instance variables automatically decorated via the `auto_frill` macro:

```ruby
class ApplicationController < ActionController::Base
  auto_frill
end
```

Now you don't need to use the `frill` method to decorate objects. They'll be automatically decorated 
before being passed off to your view.

```ruby
class FooController < ApplicationController
  def foo
    @foo = Foo.find params[:id]
  end
end
```

### 'frill' decorates individual objects _and_ collections

The `frill` helper will decorate both single objects and collections of objects. You can use it both within your controller
and within your views.

For example, inside a controller: 

```ruby
class FoosController < ApplicationController
  def index
    @foos = frill Foo.all
  end

  def show
    @foo = frill Foo.find(params[:id])
  end
end
```

Or, in a view:

```erb
<%= render frill(@foo.comments) %>
```

## A longer story

Your product manager writes the following story for you: 

```cucumber
Feature: Consistent Timestamp Presentation
  As a user
  I want "created at" timestamps presented in a uniform, localized way on the site
  So that I can easily discover the age of content on the site

  Scenario: Presenting timestamps
    When I navigate to a page that displays a created_at timestamp
    Then I should see that timestamp marked up as bold and formatted for the client's locale as follows: Month DD, YYYY HH:MM 
```

You see this and roll your eyes. You're thinking about all of the places that you show `created_at` 
timestamps on the site. Reluctantly, you roll up your sleeves and start by writing the following helper and partial:

```ruby
module ApplicationHelper
  def format_timestamp(t)
    render partial: "shared/timestamp", locals: { time: l(t, format: :long) }
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
1. Developers have to remember to manually wrap timestamps with your `format_timestamp` helper. 

After you deliver the story, your product owner says "Great! But what about the format of timestamps in the JSON api? Here's another story."

```cucumber
Feature: Consistent Timestamp Presentation in the API
  As an API consumer
  I want "created at" timestamps presented in the API in uniform way
  So that I can easily discover the age of data I consume

  Scenario: Presenting timestamps
    When I retrieve content with a "created_at" timestamp via the JSON API
    Then I should see that timestamp formatted for the client's locale as follows: Month DD, YYYY HH:MM 
```

You attempt to salvage the helper, updating it with concerns for the JSON format:

```ruby
module ApplicationHelper
  def format_timestamp(t)
    time = l t, format: :long 

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
    helpers.l super, format: :long
  end
end
```

The `frill?` method tells `Frill` when to extend an object with this module. Then we redefine the `created_at` method, 
calling super and then formatting the date with the rails localization helper `l`. The `helpers` method is made available to 
frill'ed objects; it contains the same view context that you have access to inside of views and inside of helper methods. 
You can use the `h` method as well - it's simply an alias for `helpers`.

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

```erb
<b><%=time%></b>
```

There's three important things to note: 

1. This frill comes after `TimestampFrill`. That tells `Frill` that it should only attempt to extend an object with this module after attempting to extend it with `TimestampFrill`.
1. The `frill?` method only returns true if it's an HTML request, meaning this frill won't be extended onto objects for your JSON api.
1. The `h` method gives you access to all of the normal view helper methods you expect to you use inside your views. You can also use `helpers`.

Lastly, opt objects into frilling inside your controllers by using the `frill` method: 

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

Note that if you prefer, you can configure your controllers to automatically frill all objects for presentation by calling the `auto_frill` method inside your `ApplicationController`, instead of manually having to opt them it via the `frill` method:

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



## Testing

If you're using frill inside a Rails application, you can take advantage of the "frill" rspec helper:

```ruby
require 'spec_helper'

describe HtmlTimestampFrill do
  let(:model) {
    Class.new do
      def created_at
        DateTime.new(2012, 1, 1)
      end
    end.new
  end

  context "html request" do
    subject { frill model }
    its(:created_at) { should == "<b>January 01, 2012 00:00<b>" }
  end

  context "non-html request" do
    subject { frill model, "HTTP_ACCEPT" => "application/json" }
    its(:created_at) { should == "January 01, 2012 00:00" }
  end
end
```

It will assume an html request context, and it will embue your model with `h` and `helpers` methods.

If you're attempting to test the `MyFrill.frill?` method, you'll need to supply it with stubs:

```ruby
require 'spec_helper'

describe HtmlTimestampFrill do
  let(:context) { double :view_context }

  subject { HtmlTimestampFrill.frill? double(:model, created_at: "foo"), context }

  context "given an HTML request" do
    before { context.stub_chain(:request, :format, :html?).and_return true }
    it { should be_true }
  end

  context "given a non-HTML request" do
    before { context.stub_chain(:request, :format, :html?).and_return false }
    it { should be_false }
  end
end
```

Note (2012/09/05): because of a subtle bug in RSpec, the above stub chain `stub_chain(:request, :format, :html?)` fails on the latest RSpec release (2.11.0) but is fixed in master. See issue [#587](https://github.com/rspec/rspec-rails/issues/587) and the [commit that fixes it](https://github.com/rspec/rspec-mocks/commit/05741e90083280c1b9e069350d7e3afbf4a45456).

Since frills are just modules, it's possible to test your frills in relative isolation.

```ruby
require 'spec_helper'

describe TimestampFrill do
  let(:object) do
    double :object, 
      created_at: DateTime.new(2012, 1, 1),
      h: ApplicationController.new.view_context
  end

  subject { object.extend TimestampFrill }

  its(:created_at) { should == "January 01, 2012 00:00" }
end
```

When it comes to view methods that render partials, etc., you could choose to test them with integration:

```ruby
require 'spec_helper'                                                     

class SomeModel
  def h 
    @view_context ||= ApplicationController.new.view_context
  end

  def created_at
     Time.new(2012,1,1)
  end
end   

describe HtmlTimestampFrill do                                            
  let(:object) { SomeModel.new.extend TimestampFrill }

  subject { object.extend HtmlTimestampFrill }     
  
  describe "#created_at" do
    it "should render the timestamp partial" do
      subject.created_at.strip.should == "<b>January 01, 2012 00:00</b>"
    end
  end
end
```

Or you could test them by stubbing out the view context, and simply setting up expectations on them:

```ruby
require 'spec_helper'

class SomeModel
  def h; end
  def created_at; end
end
  
describe HtmlTimestampFrill do                                            
  let(:object) { SomeModel.new }
  
  subject { object.extend HtmlTimestampFrill }
  
  describe "#created_at" do                                               
    it "should render the timestamp partial" do
      subject.h.should_receive(:render)
      subject.created_at
    end
  end
end
```

The latter can be nice if you're really just interested in testing conditional logic inside your decoration.

## Usage outside Rails

There are really just three integrations in a Rails app: the `frill` 
method inside of your controller, the `auto_frill` macro for controllers, 
plus the ability to call view helper methods inside of your module methods.

To kickoff the decoration of an object outside of a Rails application,
simply call `Frill.decorate`:

```ruby
Frill.decorate my_object, my_context
```

## Contributors

* Ben Moss
* Nicholas Greenfield

## License

MIT
