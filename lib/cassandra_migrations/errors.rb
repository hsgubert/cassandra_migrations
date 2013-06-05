# encoding: utf-8

module CassandraMigrations
  module Errors

    class CassandraError < StandardError
    end
    
    class ClientNotStartedError < CassandraError
      def initialize
        super("Cassandra.start! has not been called yet! Can't execute queries before connecting to server...")
      end
    end
    
    class MissingConfigurationError < CassandraError
      def initialize
        super("config/cassandra.yml is missing! Run 'prepare_for_cassandra .' in the rails root directory.")
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
    
    class MigrationDefinitionError < CassandraError
      def initialize(msg)
        super(msg)
      end
    end
    
  end
end
