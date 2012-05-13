#!/usr/bin/env sh

bundle exec rspec && pushd test_frill_rails && bundle exec rspec
