# encoding: utf-8

module CassandraMigrations
  module Cassandra
    module KeyspaceOperations
  
      def create_keyspace!(env)
        config = Config.configurations(env)
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
          drop_keyspace!
          raise exception
        end
      end
      
      def drop_keyspace!
        config = Config.configurations(env)
        begin
          execute("DROP KEYSPACE #{config.keyspace}")
        rescue Cql::QueryError
          raise Errors::UnexistingKeyspaceError, config.keyspace
        end
      end
    
    end
  end
end
