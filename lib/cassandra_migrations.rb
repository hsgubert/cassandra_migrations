
module CassandraMigrations
end

require 'cassandra_migrations/cassandra'
require 'cassandra_migrations/railtie' if defined?(Rails)
