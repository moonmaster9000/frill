# CHANGLOG

## v0.1.14

small bug fix - h/helpers in your frills no longer private.

## v0.1.13

You can now frill with only a subset of frills:

```ruby
def index
  @posts = frill Post.all, with: [PicturePost, TextPost, VideoPost]
end
```

## v0.1.12

You can now set request options on the "frill" rspec helper:

```ruby
subject { frill model, "HTTP_ACCEPT" => "application/json" }
```

## v0.1.11

Added "frill" helper to rspec integration.

## v0.1.10

Add "MIT" license to gem specification.

## v0.1.9

Automatically frill all of your controller instance variables via the
`auto_frill` class method.

## v0.1.8

Your frill dependency graph is now memoized on first access, instead of being recomputed
every time you frill.

## v0.1.7

LICENSE file now distributed with gem.

## v0.1.6

Internal refactoring. No new functionality. 

## v0.1.5

Bug fix: before/after failed to work correctly when joining two distinct
dependency lists.

## v0.1.4

Bug fix: multiple before and after uses could still cause an ordering issue.
Replaced naive decorator ordering with dependency graphs.

## v0.1.3

Removed the mention of "first" from the frill template.


## v0.1.2

(Ben Moss & Nicholas Greenfield)
Bug fix: multiple "after" uses could cause an ordering issue. 
