require 'frill/frill'
require 'frill/engine' if defined? Rails
require 'frill/rspec' if defined?(RSpec) and RSpec.respond_to?(:configure)
