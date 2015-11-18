# encoding: utf-8
require 'cassandra'

module CassandraMigrations
  module Cassandra
    module KeyspaceOperations

      def create_keyspace!(env)
        config = Config.configurations[env]
        validate_config(config)

        execute(
          "CREATE KEYSPACE #{config.keyspace} \
           WITH replication = { \
             'class':'#{config.replication['class']}', \
             'replication_factor': #{config.replication['replication_factor']} \
           }"
        )
        begin
          use(config.keyspace)
        rescue StandardErorr => exception
          drop_keyspace!(env)
          raise exception
        end
      end

      def drop_keyspace!(env)
        config = Config.configurations[env]
        begin
          execute("DROP KEYSPACE #{config.keyspace}")
        rescue ::Cassandra::Errors::ConfigurationError
          raise Errors::UnexistingKeyspaceError, config.keyspace
        end
      end

      private

      def validate_config(config)
        if config.keyspace.nil?
          raise Errors::MissingConfigurationError.new("Configuration of 'keyspace' is required in config.yml, but none is defined.")
        end
        unless config_includes_replication?(config)
          raise Errors::MissingConfigurationError.new("Configuration for 'replication' is required in config.yml, but none is defined.")
        end
        true
      end

      def config_includes_replication?(config)
        config.replication &&
        config.replication['class'] &&
        config.replication['replication_factor']
      end
    end
  end
end
