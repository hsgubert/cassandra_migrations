# encoding: utf-8
require 'cassandra'

module CassandraMigrations
  module Cassandra
    module KeyspaceOperations

      def create_keyspace!(env)
        config = Config.configurations[env]
        begin
          execute(
            "CREATE KEYSPACE #{config.keyspace} \
             WITH replication = { \
               'class':'#{config.replication['class']}', \
               'replication_factor': #{config.replication['replication_factor']} \
             }"
          )
          use(config.keyspace)
        rescue Exception => exception
          drop_keyspace!(env)
          raise exception
        end
      end

      def drop_keyspace!(env)
        config = Config.configurations[env]
        begin
          execute("DROP KEYSPACE #{config.keyspace}")
        rescue ::Cassandra::Errors::QueryError
          raise Errors::UnexistingKeyspaceError, config.keyspace
        end
      end

    end
  end
end
