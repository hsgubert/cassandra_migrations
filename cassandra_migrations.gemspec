# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cassandra_migrations/version'

Gem::Specification.new do |s|
  s.name        = 'cassandra_migrations'
  s.version     = CassandraMigrations::VERSION
  s.date        = '2017-10-18'
  s.license     = 'MIT'
  s.summary     = 'Cassandra schema management for a multi-environment developer.'
  s.description = 'A gem to manage Cassandra database schema for Rails. This gem offers migrations and environment specific databases out-of-the-box for Rails users.'
  s.authors     = ['Henrique Gubert', 'Brian Sam-Bodden', 'Nathan Brazil']
  s.email       = ['guberthenrique@hotmail.com', 'bsbodden@integrallis.com']
  s.homepage    = 'https://github.com/hsgubert/cassandra_migrations'
  s.require_path = 'lib'
  s.required_rubygems_version = '>= 1.8.0'

  # s.files: The files included in the gem.
  s.files = Dir['lib/**/*', 'template/**/*']

  # s.test_files: Files that are used for testing the gem.
  s.test_files = Dir['s/**/*_s.rb']

  # s.add_dependency: Production dependencies
  s.add_runtime_dependency 'cassandra-driver', '~> 3.2'
  s.add_runtime_dependency 'rake', '~> 12'
  s.add_runtime_dependency 'rails', '>= 3.2'
  s.add_runtime_dependency 'colorize', '~> 0.8'

  # s.add_development_dependency: Development dependencies
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'byebug', '~> 9.1'
  s.add_development_dependency 'bundler', '~> 1.6'
  s.add_development_dependency 'simplecov', '~> 0.14'
  s.add_development_dependency 'coveralls', '~> 0.8'
  s.add_development_dependency 'appraisal', '~> 2.2'
end
