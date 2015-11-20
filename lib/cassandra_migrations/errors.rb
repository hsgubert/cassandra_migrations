# encoding: utf-8

require 'colorize'

module CassandraMigrations
  module Errors

    class CassandraError < StandardError
      def initialize(msg)
        # Makes all exception messages red
        if msg.frozen?
          super(msg.dup.red)
        else
          super(msg.red)
        end
      end
    end

    class ClientNotStartedError < CassandraError
      def initialize
        super("Cassandra.start! has not been called yet! Can't execute queries before connecting to server...")
      end
    end

    class MissingConfigurationError < CassandraError
      def initialize(msg=nil)
        super(msg || "config/cassandra.yml is missing! Run 'prepare_for_cassandra .' in the rails root directory.")
      end
    end

    class UnexistingKeyspaceError < CassandraError
      def initialize(keyspace, e = nil)
        super(%[Keyspace #{keyspace} does not exist. Run rake cassandra:create. #{"(#{e.message})" if e}])
      end
    end

    class ClusterError < CassandraError
      def initialize(cluster_opts, e = nil)
        super(%[Could not connect to cluster at #{cluster_opts}. Is Cassandra running? #{"(#{e.message})" if e}])
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
