# encoding: utf-8

require 'yaml'
require 'cassandra'
require_relative 'cql-rb-wrapper'
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

      restart
    end

    def self.restart
      if client
        client.close if client.connected?
        self.client = nil
      end

      start!
    end

    def self.shutdown!
      raise Errors::ClientNotStartedError unless client

      client.close if client.connected?
      self.client = nil
    end

    def self.using_keyspace(keyspace, &block)
      use(keyspace)
      block.call
      use(Config.keyspace)
    end

    def self.use(keyspace)
      connect_to_server unless client

      begin
        client.use(keyspace)
      rescue Exception => e # keyspace does not exist
        puts "#{e} : #{e.message}"
        raise Errors::UnexistingKeyspaceError, keyspace
      end
    end

    def self.execute(*cql)
      connect_to_server unless client
      Rails.logger.try(:info, "\e[1;35m [Cassandra Migrations] \e[0m #{cql.to_s}")
      result = client.execute(*cql)
      QueryResult.new(result) if result
    end

  private

    def self.connect_to_server
      connection_params = Config.connection_config_for_env

      begin
        self.client = Client.connect(connection_params)
      rescue Ione::Io::ConnectionError => e
        raise Errors::ConnectionError, e.message
      end
    end
  end
end
