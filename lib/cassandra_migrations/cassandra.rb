# encoding: utf-8

require 'yaml'
require 'cql'
require 'cassandra_migrations/cassandra/queries'
require 'cassandra_migrations/cassandra/query_result'
require 'cassandra_migrations/cassandra/keyspace_operations'

module CassandraMigrations
  module Cassandra
    extend Queries
    extend KeyspaceOperations
  
    mattr_accessor :client
    
    def self.start!
      begin
        # setup keyspace use
        use(Config.keyspace)
      rescue Errors::MissingConfigurationError
        # It's acceptable to not have a configuration file, that's why we rescue this exception.
        # On the other hand, if the user try to execute a query this same exception won't be rescued
        Rails.logger.try(:warn, "There is no config/cassandra.yml. Skipping connection to Cassandra...") 
      end
    end
    
    def self.restart!
      raise Errors::ClientNotStartedError unless client

      client.close if client && client.connected?
      self.client = nil
      start!
    end
    
    def self.shutdown!
      raise Errors::ClientNotStartedError unless client

      client.close if client.connected?
      self.client = nil
    end
    
    def self.use(keyspace)
      connect_to_server unless client

      begin
        client.use(keyspace)
      rescue Cql::QueryError # keyspace does not exist
        raise Errors::UnexistingKeyspaceError, keyspace
      end
    end

    def self.execute(cql)
      connect_to_server unless client
      result = client.execute(cql)
      QueryResult.new(result) if result
    end  
    
  private
    
    def self.connect_to_server
      Rails.logger.try(:info, "Connecting to Cassandra on #{Config.host}:#{Config.port}")
      
      begin
        self.client = Cql::Client.new(:host => Config.host, :port => Config.port)
        client.connect
      rescue Cql::Io::ConnectionError => e
        raise Errors::ConnectionError, e.message      
      end
    end
  end
end
