# encoding: utf-8

require 'yaml'
require 'cql'
require 'cassandra_migrations/cassandra/queries'
require 'cassandra_migrations/cassandra/keyspace_operations'

module CassandraMigrations
  module Cassandra
    extend Queries
    extend KeyspaceOperations
  
    mattr_accessor :client
    
    def self.start!
      # setup keyspace use
      use(Config.keyspace)
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
      client.execute(cql)
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
