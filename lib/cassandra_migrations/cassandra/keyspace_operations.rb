# encoding: utf-8

module CassandraMigrations
  module Cassandra
    module KeyspaceOperations
  
      def create_keyspace!
        begin
          execute(
            "CREATE KEYSPACE #{Config.keyspace} \
             WITH replication = { \ 
               'class':'#{Config.replication['class']}', \
               'replication_factor': #{Config.replication['replication_factor']} \
             }"
          )
          use(Config.keyspace)
        rescue Exception => exception
          drop_keyspace!
          raise exception
        end
      end
      
      def drop_keyspace!
        begin
          execute("DROP KEYSPACE #{Config.keyspace}")
        rescue Cql::QueryError
          raise Errors::UnexistingKeyspaceError, keyspace
        end
      end
    
    end
  end
end
