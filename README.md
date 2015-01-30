[![Gem Version](https://badge.fury.io/rb/cassandra_migrations.png)](http://badge.fury.io/rb/cassandra_migrations)
[![Code Climate](https://codeclimate.com/github/hsgubert/cassandra_migrations.png)](https://codeclimate.com/github/hsgubert/cassandra_migrations)

Cassandra Migrations
====================

**Cassandra schema management for a multi-environment development.**

A gem to manage Cassandra database schema for Rails. This gem offers migrations and environment specific databases out-of-the-box for Rails users.

This enables you to use Cassandra in an organized way, combined with your ActiveRecord relational database.

# Requirements

- Cassandra 1.2 or higher with the native_transport_protocol turned on ([Instructions to install cassandra locally](https://github.com/hsgubert/cassandra_migrations/wiki/Preparing-standalone-Cassandra-in-local-machine))
- Ruby 1.9
- Rails > 3.2

# Installation

    gem install cassandra_migrations

# Quick start

### Configure Cassandra

The native transport protocol (sometimes called binary protocol, or CQL protocol) is not on by default on all version of Cassandra. If it is not you can enable by editing the `CASSANDRA_DIR/conf/cassandra.yaml` file on all nodes in your cluster and set `start_native_transport` to `true`. You need to restart the nodes for this to have effect.

### Prepare Project

In your rails root directory run:

    prepare_for_cassandra .
    
Which create the `config/cassandra.yml`

### Configuring cassandra access

Open the newly-created `config/cassandra.yml` and configure the database name for each of the environments, just like you would do for your regular database. The other options defaults should be enough for now.

```ruby
development:
  hosts: ['127.0.0.1']
  port: 9042
  keyspace: 'my_keyspace_name'
  replication:
    class: 'SimpleStrategy'
    replication_factor: 1
```

>> *SUPPORTED CONFIGURATION OPTIONS*: For a list of supported options see the docs for [Cassandra module, connect method](http://datastax.github.io/ruby-driver/api/) in the [DataStax Ruby Driver](https://github.com/datastax/ruby-driver)

### Create your database

There are a collection of rake tasks to help you manage the cassandra database (`rake cassandra:create`, `rake cassandra:migrate`, `rake cassandra:drop`, etc.). For now this one does the trick:

    rake cassandra:setup

### Creating a C* Table

    rails generate cassandra_migration create_posts

In your migration file, make it create a table and drop it on its way back:

```ruby
class CreatePosts < CassandraMigrations::Migration
  def up
    create_table :posts do |p|
      p.integer :id, :primary_key => true
      p.timestamp :created_at
      p.string :title
      p.text :text
    end
  end

  def self.down
    drop_table :posts
  end
end
```

And now run:

    rake cassandra:migrate

To create a table with compound primary key just specify the primary keys on table creation, i.e.:

```ruby
class CreatePosts < CassandraMigrations::Migration
  def up
    create_table :posts, :primary_keys => [:id, :created_at] do |p|
      p.integer :id
      p.timestamp :created_at
      p.string :title
      p.text :text
    end
  end

  def self.down
    drop_table :posts
  end
end
```

To create a table with a compound partition key specify the partition keys on table creation, i.e.:

```ruby
class CreatePosts < CassandraMigrations::Migration
  def up
    create_table :posts, :partition_keys => [:id, :created_month], :primary_keys => [:created_at] do |p|
      p.integer :id
      p.string :created_month
      p.timestamp :created_at
      p.string :title
      p.text :text
    end
  end

  def self.down
    drop_table :posts
  end
end
```

To create a table with a secondary index you add it similar to regular rails indexes, i.e.:

```ruby
class CreatePosts < CassandraMigrations::Migration
  def up
    create_table :posts, :primary_keys => [:id, :created_at] do |p|
      p.integer :id
      p.timestamp :created_at
      p.string :title
      p.text :text
    end

    create_index :posts, :title, :name => 'by_title'
  end

  def self.down
 	 drop_index 'by_title'

    drop_table :posts
  end
end
```

#### Passing options to create_table

The create_table method allow do pass a hash of options for:

* Clustering Order (clustering_order): A string such as 'a_decimal DESC'
* Compact Storage (compact_storage): Boolean, true or false
* Wait before GC (gc_grace_seconds): Default: 864000 [10 days]
* Others: See [CQL Table Properties](http://www.datastax.com/documentation/cql/3.1/cql/cql_reference/tabProp.html)

Cassandra Migration will attempt to pass through the properties to the CREATE TABLE command.

Examples:

```ruby
class WithClusteringOrderMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists, options: {
                                      clustering_order: 'a_decimal DESC',
                                      compact_storage: true,
                                      gc_grace_seconds: 43200
                                    } do |t|
      t.uuid :id, :primary_key => true
      t.decimal :a_decimal
    end
  end
end
```

#### Using Alternate/Additional Keyspaces

The using_keyspace method in a migration allows to execute that migration in
the context of a specific keyspace:

```ruby
class WithAlternateKeyspaceMigration < CassandraMigrations::Migration
  def up
    using_keyspace('alternative') do
      create_table :collection_lists, options: {compact_storage: true} do |t|
        t.uuid :id, :primary_key => true
        t.decimal :a_decimal
      end
    end
  end
end
```

The overall workflow for a multiple keyspace env:
- define all of your keyspaces/environment combinations as separate environments
  in `cassandra.yml`. You probably want to keep your main or default keyspace as
  just plain `development` or 'production`, especially if you're using the
  queries stuff (so as to confuse Rails as little as possible)
- make sure to run `rake cassandra:create` for all of them
- if you use `using_keyspace` in all your migrations for keyspaces defined in
  environments other than the standard Rails ones, you won't have to run them for
  each 'special' environment.

> *Side Note*: If you're going to be using multiple keyspaces in one application
> (specially with cql-rb), you probably want to just fully qualify your table names
> in your queries rather than having to call `USE <keyspace>` all over the place.
> Specially since cql-rb encourages you to only have one client object per application.

There are some other helpers like `add_column` too.. take a look inside!

### Migrations for Cassandra Collections

Support for C* collections is provided via the list, set and map column types.

```ruby

class CollectionsListMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.list :my_list, :type => :string
      t.set :my_set, :type => :float
      t.map :my_map, :key_type => :uuid, :value_type => :float
    end
  end
end

```

### Querying cassandra

There are two ways to use the cassandra interface provided by this gem

#### 1. Acessing through query helpers

```ruby
# selects all posts
CassandraMigrations::Cassandra.select(:posts)

# more complex select query
CassandraMigrations::Cassandra.select(:posts,
  :projection => 'title, created_at',
  :selection => 'id > 1234',
  :order_by => 'created_at DESC',
  :limit => 10
)

# selects single row by uuid
CassandraMigrations::Cassandra.select(:posts,
  :projection => 'title, created_at',
  :selection => 'id = 6bc939c2-838e-11e3-9706-4f2824f98172',
  :allow_filtering => true  # needed for potentially expensive queries
)

# adding a new post
CassandraMigrations::Cassandra.write!(:posts, {
  :id => 9999,
  :created_at => Time.current,
  :title => 'My new post',
  :text => 'lorem ipsum dolor sit amet.'
})

# adding a new post with TTL
CassandraMigrations::Cassandra.write!(:posts,
  {
    :id => 9999,
    :created_at => Time.current,
    :title => 'My new post',
    :text => 'lorem ipsum dolor sit amet.'
  },
  :ttl => 3600
)

# updating a post
CassandraMigrations::Cassandra.update!(:posts, 'id = 9999',
  :title => 'Updated title'
)

# updating a post with TTL
CassandraMigrations::Cassandra.update!(:posts, 'id = 9999',
  { :title => 'Updated title' },
  :ttl => 3600
)

# deleting a post
CassandraMigrations::Cassandra.delete!(:posts, 'id = 1234')

# deleting a post title
CassandraMigrations::Cassandra.delete!(:posts, 'id = 1234',
  :projection => 'title'
)

# deleting all posts
CassandraMigrations::Cassandra.truncate!(:posts)
```

#### 4. Manipulating Collections

Given a migration that generates a set type column as shown next:

```ruby
class CreatePeople < CassandraMigrations::Migration
  def up
    create_table :people, :primary_keys => :id do |t|
      t.uuid :id
      t.string :ssn
      ...
      t.set :emails, :type => :string
    end
  end

  ...
end
```

You can add new emails to the existing collection:

```ruby
CassandraMigrations::Cassandra.update!(:people, "ssn = '867530900'",
                                       {emails: ['jenny@goodtimes.com', 'jenn@numberonthewall.net']},
                                       {operations: {emails: :+}})
```

You can remove emails from the collection:

```ruby
CassandraMigrations::Cassandra.update!(:people, "ssn = '867530900'",
                                       {emails: ['jenny@goodtimes.com']},
                                       {operations: {emails: :-}})
```

Or, completely replace the existing values in the collection:

```ruby
CassandraMigrations::Cassandra.update!(:people, "ssn = '867530900'",
                                       {emails: ['jenny@goodtimes.com', 'jenn@numberonthewall.net']})
```

The same operations (addition `:+` and subtraction `:-`) are supported by all collection types.

Read more about C* collections at http://cassandra.apache.org/doc/cql3/CQL.html#collections


#### 3. Using raw CQL3

```ruby
CassandraMigrations::Cassandra.execute('SELECT * FROM posts')
```

### Reading query results

Select queries will return an enumerable object over which you can iterate. All other query types return `nil`.

```ruby
CassandraMigrations::Cassandra.select(:posts).each |post_attributes|
  puts post_attributes
end

# => {'id' => 9999, 'created_at' => 2013-05-20 18:43:23 -0300, 'title' => 'My new post', 'text' => 'lorem ipsum dolor sit amet.'}
```

If your want some info about the table metadata just call it on a query result:
```ruby
CassandraMigrations::Cassandra.select(:posts).metadata

# => {'id' => :integer, 'created_at' => :timestamp, 'title' => :varchar, 'text' => :varchar}
```

### Using uuid data type

Please refer to the wiki: [Using uuid data type](https://github.com/hsgubert/cassandra_migrations/wiki/Using-uuid-data-type)

### Deploy integration with Capistrano

This gem comes with built-in compatibility with Passenger and its smart spawning functionality, so if you're using Passenger all you have to do is deploy and be happy!

To add cassandra database creation and migrations steps to your Capistrano recipe, just add the following line to you deploy.rb:  
`require 'cassandra_migrations/capistrano'`

# Acknowledgements

This gem is built upon the official [Ruby Driver for Apache Cassandra](https://github.com/datastax/ruby-driver) by DataStax.
Which supersedes the [cql-rb](https://github.com/iconara/cql-rb) gem (thank you Theo for doing an awesome job).
