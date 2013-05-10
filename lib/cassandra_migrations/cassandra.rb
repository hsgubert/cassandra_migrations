# encoding: utf-8

require 'yaml'
require 'cql'
require 'cassandra_migrations/cassandra/query'
require 'cassandra_migrations/cassandra/errors'
require 'cassandra_migrations/cassandra/migrator'

module CassandraMigrations::Cassandra
  extend Query
  
  mattr_accessor :client
  mattr_accessor :config 
  
  def self.start!
    connect_to_server unless client
    
    # setup keyspace use
    begin
      use(config['keyspace'])
    rescue Cql::QueryError # keyspace does not exist
      raise Errors::UnexistingKeyspaceError, config['keyspace']
    end
  end
  
  def self.restart!
    self.client = nil
    self.config = nil
    start!
  end
  
  def self.shutdown!
    if client
      client.close
      self.client = nil
    end
      
    self.config = nil
  end
  
  def self.create_keyspace!
    connect_to_server unless client
    
    begin
      execute(
        "CREATE KEYSPACE #{config['keyspace']} \
         WITH replication = { \ 
           'class':'#{config['replication']['class']}', \
           'replication_factor': #{config['replication']['replication_factor']} \
         }"
      )
      use(config['keyspace'])
      execute("CREATE TABLE metadata (data_name varchar PRIMARY KEY, data_value varchar)") 
      write("metadata", {:data_name => 'version', :data_value => '0'})
    rescue Exception => exception
      drop!
      raise exception
    end
  end
  
  def self.drop!
    connect_to_server unless client
    
    begin
      execute("DROP KEYSPACE #{config['keyspace']}")
    rescue Cql::QueryError
      raise Errors::UnexistingKeyspaceError, config['keyspace']
    end
  end
  
  def self.use(keyspace)
    raise Errors::ClientNotStartedError unless client
    client.use(keyspace)
  end

  def self.execute(cql)
    raise Errors::ClientNotStartedError unless client
    client.execute(cql)
  end  
  
private
  
  def self.connect_to_server
    load_config
    
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