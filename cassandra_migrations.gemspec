Gem::Specification.new do |s|
  s.name        = 'cassandra_migrations'
  s.version     = '0.0.1.pre0'
  s.date        = '2013-03-29'
  s.summary     = "Cassandra schema management for a multi-environment developer."
  s.description = "A gem to manage Cassandra database schema for Rails. This gem offers migrations and environment specific databases out-of-the-box for Rails users."
  s.authors     = ["Henrique Gubert"]
  s.email       = 'guberthenrique@hotmail.com'
  s.files       = Dir["{lib}/**/*"]
  s.homepage    = 'https://github.com/hsgubert/cassandra_migrations'
  s.require_path = 'lib'
  
  s.required_rubygems_version = ">= 1.8.0"
  
  s.add_dependency "cql-rb", "1.0.0.pre3"
  s.add_dependency "rake", "~>10"
  s.add_dependency "rails", "~>3.2"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "debugger"
end