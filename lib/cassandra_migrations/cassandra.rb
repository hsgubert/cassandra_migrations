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
      puts "  using_keyspace(#{keyspace})"
      use(keyspace)
      begin
        # invoke the block in the other namespace
        block.call
      ensure
        # always switch back to the main keyspace
        use(Config.keyspace)
      end
    end

    ##
    # Use the keyspace specified in a particular environment entry of the config/cassandra.yml file.
    # In order for this to work, such environemnts in the YAML file must have the format
    # of {prefix}-{environment}, where {prefix} is some name, and {environment} is one of the main Rails
    # environment names.  For example, by defining foo1-development, foo1-test and foo1-production in
    # config/cassandra.yml, a migration can invoke use_keyspace("foo1") to target the keyspace
    # specified therein, in accordance with the Rails environment names.  This approach is better than
    # the using_keyspace() method because it allows a migration targeting another keyspace to be usable
    # in all environments the application needs to run in.
    def self.use_keyspace(prefix, &block)
      env_name = "#{prefix.to_s}-#{Rails.env}"
      keyspace = CassandraMigrations::Config.configurations[env_name].keyspace
      puts "  Use keyspace #{keyspace} from #{env_name} in config/cassandra.yml"
      use(keyspace)
      begin
        # invoke the block in the other namespace
        block.call
      ensure
        # always switch back to the main keyspace
        use(Config.keyspace)
      end
    end

    def self.use(keyspace)
      connect_to_server unless client

      begin
        client.use(keyspace.to_s)
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
