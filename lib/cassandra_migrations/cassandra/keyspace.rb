# encoding: utf-8

module CassandraMigrations::Cassandra
  module Keyspace
  
    def self.create_keyspace!
      begin
        execute(
          "CREATE KEYSPACE #{config['keyspace']} \
           WITH replication = { \ 
             'class':'#{config['replication']['class']}', \
             'replication_factor': #{config['replication']['replication_factor']} \
           }"
        )
        use(config['keyspace'])
      rescue Exception => exception
        drop_keyspace!
        raise exception
      end
    end
    
    def self.drop_keyspace!
      begin
        execute("DROP KEYSPACE #{config['keyspace']}")
      rescue Cql::QueryError
        raise Errors::UnexistingKeyspaceError, config['keyspace']
      end
    end
    
  end
end
