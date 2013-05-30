# encoding: utf-8

module CassandraMigrations
  module Errors

    class CassandraError < StandardError
    end
    
    class ClientNotStartedError < CassandraError
      def initialize
        super("Cassandra.start has not been called yet! Can't execute queries before connecting to server...")
      end
    end
    
    class MissingConfigurationError < CassandraError
      def initialize
        super("config/cassandra.yml is missing use this as example: \n\
               development: \n\
                 host: '127.0.0.1' \n\
                 port: 9042 \n\
                 keyspace: 'lme_smart_grid_server_development' \n\
                 replication: \n\
                   class: 'SimpleStrategy' \n\
                   replication_factor: 1
              ")
      end
    end
    
    class UnexistingKeyspaceError < CassandraError
      def initialize(keyspace)
        super("Keyspace #{keyspace} does not exist. Run rake cassandra:create.")
      end
    end
    
    class ConnectionError < CassandraError
      def initialize(msg)
        super(msg)
      end
    end
    
  end
end
