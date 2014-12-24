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
    @cluster = Cassandra.cluster(options)
    self.new(@cluster)
  end

  def use(keyspace)
    if @sessions[keyspace]
      @session = @sessions[keyspace]
    else
      @session = @cluster.connect(keyspace)
      @sessions[keyspace] = @session
    end
  end

  def initialize(cluster, keyspace = nil)
    @cluster = cluster
    @sessions = {}
    if keyspace
      @session = cluster.connect(keyspace)
      @sessions[keyspace] = @session
    else
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
    @session.close
  end

  def keyspace
    @session.keyspace
  end

  def connected?
    @session.instance_variable_get('@state') == :connected
  end
end
