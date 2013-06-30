Cassandra Migrations
====================

**Cassandra schema management for a multi-environment developer.**

A gem to manage Cassandra database schema for Rails. This gem offers migrations and environment specific databases out-of-the-box for Rails users.

This enables you to use Cassandra in an organized way, combined with your ActiveRecord relational database.

# Requirements

- Cassandra 1.2 or higher with the native_transport_protocol turned on ([Instructions to install cassandra locally](https://github.com/hsgubert/cassandra_migrations/wiki/Preparing-standalone-Cassandra-in-local-machine))
- Ruby 1.9
- Rails 3.2 _(not tested with Rails 4 yet, volunteers are welcome!)_

# Installation

    gem install --prerelease cassandra_migrations

# Quick start

### Configure Cassandra

The native transport protocol (sometimes called binary protocol, or CQL protocol) is not on by default in Cassandra 1.2, to enable it edit the `CASSANDRA_DIR/conf/cassandra.yaml` file on all nodes in your cluster and set `start_native_transport` to `true`. You need to restart the nodes for this to have effect.

### Prepare Project

In your rails root directory:

    prepare_for_cassandra .
    
### Configuring cassandra access

Open your newly-created `config/cassandra.yml` and configure the database name for each of the environments, just like you would do for your regular database. The other options defaults should be enough for now.

```ruby
development:
  host: '127.0.0.1'
  port: 9042
  keyspace: 'my_keyspace_name'
  replication:
    class: 'SimpleStrategy'
    replication_factor: 1
```

### Create your database

There are a collection of rake tasks to help you manage the cassandra database (`rake cassandra:create`, `rake cassandra:migrate`, `rake cassandra:drop`, etc.). For now this one does the trick:

    rake cassandra:setup

### Create a test table

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
CassandraMigrations::Cassandra.delete!(:posts, 'id = 1234'
  :projection => 'title'
)

# deleting all posts
CassandraMigrations::Cassandra.truncate!(:posts)
```

#### 2. Using raw CQL3

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

### Deploy integration with Capistrano

This gem comes with built-in compatibility with Passenger and its smart spawning functionality, so if you're using Passenger all you have to do is deploy and be happy!

To add cassandra database creation and migrations steps to your Capistrano recipe, just add the following line to you deploy.rb:  
`require 'cassandra_migrations/capistrano'`

# Acknowledgements

This gem is built upon the [cql-rb](https://github.com/iconara/cql-rb) gem, and I thank Theo for doing an awesome job working on this gem for us.


