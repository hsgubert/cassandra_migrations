# encoding: utf-8

require 'cassandra'
require 'ione'

class PreparedStatement
  attr_reader :statement

  def initialize(client, statement)
    @client = client
    @statement = statement
  end

  def execute(*args)
    @client.execute(@statement, *args)
  end
end

class BatchStatement
  def initialize(client, batch)
    @client = client
    @batch = batch
  end

  def execute(options = {})
    @client.execute(@batch, options)
  end

  def add(*args)
    @batch.add(*args)
    self
  end
end

class Client
  def self.connect(options)
    Rails.logger.try(:info, "Connecting to Cassandra cluster: #{options}")

    unless @cluster = Cassandra.cluster(options)
      raise CassandraMigrations::Errors::ClusterError.new(options)
    end

    self.new(@cluster)
  end

  def use(keyspace)
    if @sessions[keyspace]
      @session = @sessions[keyspace]
    else
      Rails.logger.try(:info, "Creating Cassandra session: #{keyspace.inspect}")
      @session = @cluster.connect(keyspace)
      @sessions[keyspace] = @session
    end
  end

  def initialize(cluster, keyspace = nil)
    @cluster = cluster
    @sessions = {}
    if keyspace
      Rails.logger.try(:info, "Creating Cassandra session: #{keyspace.inspect}")
      @session = cluster.connect(keyspace)
      @sessions[keyspace] = @session
    else
      Rails.logger.try(:info, "Creating Cassandra session: [no keyspace]")
      @session = @cluster.connect()
      @sessions[:default] = @session
    end
  end

  def execute(*args)
    @session.execute(*args)
  end

  def prepare(statement, options = {})
    s = @session.prepare(statement, options)
    PreparedStatement.new(self, s)
  end

  def batch(type = :logged, options = {})
    batch = BatchStatement.new(self, @session.send(:"#{type}_batch"))
    if block_given?
      yield(batch)
      batch.execute(options)
    else
      batch
    end
  end

  def close
    Rails.logger.try(:info, "Closing Cassandra session: #{@session.inspect}")
    @session.close
  end

  def keyspace
    @session.keyspace
  end

  def connected?
    @session.instance_variable_get('@state') == :connected
  end
end
