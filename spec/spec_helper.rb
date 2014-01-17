require 'bundler'
Bundler.setup

require 'simplecov'
require 'coveralls'
Coveralls.wear!

require 'rails/all'

require 'rspec'
require 'cassandra_migrations'

SimpleCov.command_name 'Unit Tests'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "/spec/"
end
