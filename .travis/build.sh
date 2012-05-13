#!/usr/bin/env bash

bundle exec rspec && pushd test_frill_rails && bundle exec rspec
