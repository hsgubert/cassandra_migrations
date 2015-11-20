# Cassandra Migrations
[![Gem Version](https://badge.fury.io/rb/cassandra_migrations.png)](http://badge.fury.io/rb/cassandra_migrations)
[![Code Climate](https://codeclimate.com/github/hsgubert/cassandra_migrations.png)](https://codeclimate.com/github/hsgubert/cassandra_migrations)

## Description
Cassandra Migrations is a Cassandra database schema migration library for Rails applications.

This gem provides:
  * Multi-environment database configuration
  * Versioned CQL schema migration management
  * A schema modification DSL for simplified migration code
  * Rake tasks for database schema management
  * Support for forked processes

Use Cassandra in an organized and familiar way, without changing how you work with your ActiveRecord relational database schema.

## Requirements

- Cassandra >= 1.2, using the native transport protocol
- Ruby >= 1.9
- Rails >= 3.2

## Installation

```ruby
gem install cassandra_migrations
```

or, with bundler, add the following to your gemfile:

```
gem 'cassandra_migrations'
```

## Configuration

Similar to how `config/database.yml` stores your relational databse configuration, `config/cassandra.yml` stores your cassandra database configuration.

```
rails g cassandra_configuration
```

This will create the `config/cassandra.yml` with default settings. Configure the database names for each of your environments.

```yml
development:
  hosts:
    - 127.0.0.1
  port: 9042
  keyspace: my_keyspace_dev
  replication:
    class: SimpleStrategy
    replication_factor: 1
```

These are the minimum options to get started, for advanced configuration, read about [Database Configuration Options](wiki/Database Configuration Options).

Assuming your Cassandra database is running, you may now create your keyspace:

```bash
rake cassandra:create
```

## Migrations

Similar to how `db/migrate/` stores your relational databse schema migration files, `db/cassandra_migrate/` stores your Cassandra schema migration files.

``` bash
rails g cassandra_migration create_posts
```

This will create a versioned migration in `db/cassandra_migrate/`, with familiar `up` and `down` methods that will be executed when applying or rolling back a migration, respectively.

```ruby
class CreatePosts < CassandraMigrations::Migration
  def up
  end

  def down
  end
end
```
You may call `execute` from these methods to execute CQL statements to your configured keyspace.

### Cassandra Migrations DSL

For increased readability and ease of use, there is also a familiar DSL available from the migration methods.

```ruby
class CreatePosts < CassandraMigrations::Migration
  def up
    create_table :posts,
                 partition_keys: [:id, :created_month],
                 primary_keys:   [:created_at] do |t|
      t.integer   :id
      t.string    :created_month
      t.timestamp :created_at
      t.string    :title
      t.string    :category
      t.set       :tags, type: :float
      t.map       :my_map, key_type: :uuid, value_type: :float
      t.text      :content
    end

    create_index :posts, :category, name: 'posts_by_category'
  end

  def down
    drop_index 'posts_by_category'
    drop_table :posts
  end
end
```

Use the following type methods for fields:

* `text`
* `integer`
* `decimal`
* `float`
* `double`
* `boolean`
* `uuid`
* `timeuuid`
* `inet`
* `timestamp`
* `datetime`
* `binary`
* `list` (with `type` option)
* `set` (with `type` option)
* `map` (with `key_type` and `value_type` options)

For more details on the DSL's types, advanced table options, keyspace manipulation, or other schema statment methods, read about the [Migration DSL](wiki/Migration DSL).

### Rake Tasks

There are a collection of familiar rake tasks to help you manage your cassandra databases.

  * **`rake cassandra:create`** Creates the configured keyspace in `config/cassandra.yml`.
  * **`rake cassandra:drop`** Drops the configured keyspace in `config/cassandra.yml`.
  * **`rake cassandra:migrate`** Runs migrations that have not run yet.
  * **`rake cassandra:rollback`** Rolls back the latest migration that has been applied.
  * **`rake cassandra:migrate:reset`**  Runs `cassandra:drop`, `cassandra:create` and `cassandra:migrate`.

Each rake task will be run against the database that is configured for the current environment (via `RAILS_ENV`).

```
rake cassandra:migrate
```

```bash

== CreatePosts: migrating =====================================================
  create_table(posts)
  -> CREATE TABLE posts (id int, created_month varchar, created_at timestamp, title varchar, category varchar, content text, PRIMARY KEY((id, created_month), created_at))
  create_index(posts)
  -> CREATE INDEX posts_by_category ON posts (category)
== CreatePosts: migrated (0.3448s) ============================================

Migrated 1 version(s) up.
```

For more details on available rake tasks and options, read about [Rake Tasks](wiki/Rake Tasks).

## Query Helpers

When a migration requires working with data, not just schema, one option is using the Cassandra Migration query classes.

```ruby
CassandraMigrations::Cassandra.select(:posts)
```

```ruby
new posts = CassandraMigrations::Cassandra.select(:posts,
  projection: 'title, created_at',
  selection: 'id > 1234',
  order_by: 'created_at DESC',
  limit: 10
)

new_posts.each do |post|
  CassandraMigrations::Cassandra.update!(:posts,
    "id = #{post['id']}",
    {tags: ['new']},
    {operations: {tags: :+}})
end
```

For more details, options, and examples, read about the [Query Helpers](wiki/Query Helpers).


## Deployment

### Passenger

Cassandra Migrations has built-in support for Passenger's forked process model (e.g. smart spawning).

### Other forked web servers (Puma, Unicorn, etc.)

Each fork should contain its own session to avoid deadlock and other issues. Restart the connection after the process has forked.

```
# config/puma.rb
on_worker_boot do
  # re-establish the connection in this process fork
  CassandraMigrations::Cassandra.restart
end
```

### Capistrano

To add cassandra database creation and migrations steps to your Capistrano recipe, add the following line to you deploy.rb:
`require 'cassandra_migrations/capistrano'`

## Acknowledgements

This gem is built upon the official [Ruby Driver for Apache Cassandra](https://github.com/datastax/ruby-driver) by DataStax.
Which supersedes the [cql-rb](https://github.com/iconara/cql-rb) gem (thank you Theo for doing an awesome job).
