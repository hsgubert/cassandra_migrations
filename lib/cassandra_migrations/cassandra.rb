# encoding: utf-8

require 'yaml'
require 'cql'
require 'cassandra_migrations/cassandra/query'
require 'cassandra_migrations/cassandra/keyspace'
require 'cassandra_migrations/cassandra/errors'
require 'cassandra_migrations/cassandra/migrator'

module CassandraMigrations::Cassandra
  extend Query
  extend Keyspace
  extend Migrator
  
  mattr_accessor :client
  mattr_accessor :config 
  
  def self.start!
    # setup keyspace use
    load_config
    use(config['keyspace'])
  end
  
  def self.restart!
    raise Errors::ClientNotStartedError unless client

    client.close if client && client.connected?
    self.client = nil
    self.config = nil
    start!
  end
  
  def self.shutdown!
    raise Errors::ClientNotStartedError unless client

    client.close if client.connected?
    self.client = nil
    self.config = nil
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
    load_config unless config
    
    Rails.logger.try(:info, "Connecting to Cassandra on #{config['host']}:#{config['port']}")
    
    begin
      self.client = Cql::Client.new(:host => config['host'], :port => config['port'])
      client.connect
    rescue Cql::Io::ConnectionError => e
      raise Errors::ConnectionError, e.message      
    end
  end
  
  def self.load_config
    begin
      self.config = YAML.load_file(Rails.root.join("config", "cassandra.yml"))[Rails.env]
    rescue Errno::ENOENT
      raise Errors::MissingConfigurationError
    end
  end
end
