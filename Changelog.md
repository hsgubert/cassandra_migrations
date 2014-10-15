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
