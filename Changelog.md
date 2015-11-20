### 0.2.5 / 2015-11-20
* Enhancements
  * Deprecates `cassandra:setup` task in favor of `cassandra:migrate:reset`
  * Replaces `prepare_for_cassandra` script with rails `cassandra_configuration` generator
  * More helpful logging and error messages around cluster connection and `cassandra:create` task
* Bug fixes
  * Cassandra cluster and sessions connections were not working with Spring

### 0.2.4 / 2015-11-18
* Yanked!

### 0.2.3 / 2015-05-03
* Enhancements
  * Single quotes in value strings are automatically escaped
  * Support for [secondary options](http://datastax.github.io/ruby-driver/api/session/#execute_async-instance_method) with the `select` method
* Bug fixes
  * Removed `QueryError` since it no longer is an error module in the Cassandra Ruby driver
  * Fixed list type not working


### 0.2.2 / 2015-03-01
* Enhancements
  * Support for inserting nil values from Rails into C*
  * Spring initializer used in cql-rb wrapper
  * Upgraded C* version (cassandra-driver dependency) to v2.1.1


### 0.2.1 / 2014-12-23
* Enhancements
  * Upgraded C* version (cassandra-driver dependency) to v1.1.1
* Breaking changes
  * Removed `add_options` method from `table_operations.rb`. [See issue #47](https://github.com/hsgubert/cassandra_migrations/issues/47)

### 0.2.0 / 2014-10-15

* Enhancements
  * Refactored code base to use the official ('cassandra-driver', '~> 1.0.0.beta.3') [DataStax C* driver](https://rubygems.org/gems/cassandra-driver)
  * Codebase remains backwards compatible
  * Should support new features available via the new driver (authentication, server/client certs, compression and other connection params). See [driver docs](http://datastax.github.io/ruby-driver/api/)
  * Updated to the latest version of RSpec (3.1.0)
  * Updated other development dependencies (bundler, simplecov, coveralls)

### 0.1.0 / 2014-06-18

* Enhancements
  * Support for counter type in migrations
  * Multiple keyspace support with using_keyspace method
  * Update ruby CQL 3 driver (now cql-rb 2.0.0)
  * Support for CREATE TABLE options/properties (CLUSTERING ORDER, COMPACT STORAGE, gc_grace_seconds)

### 0.0.9 / 2014-04-25 (Oops release - Yanked!)

* Enhancements
  * Improved data types resolution in migrations
  * Added decimal type
  * Ruby 2.1.0 for development

### 0.0.8 / 2014-04-25

* Enhacements
  * Add support for decimal type
  * Update ruby CQL 3 driver (now cql-rb 2.0.0.pre1)

### 0.0.3 / 2013-07-21

* Enhancements
  * Add support for uuid data type
  * Update ruby CQL 3 driver (now cql-rb 1.0.1)

### 0.0.2 / 2013-06-30

* Enhancements
  * Add update! query helper
  * Add support for :ttl option on write! and update! query helpers

### 0.0.1 / 2013-06-21

* Initial release
