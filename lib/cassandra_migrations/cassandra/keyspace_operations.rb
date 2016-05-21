# encoding: utf-8
require 'cassandra'

module CassandraMigrations
  module Cassandra
    module KeyspaceOperations

      def create_keyspace!(env)
        config = Config.configurations[env]
        execute(create_keyspace_statement(config))
        begin
          use(config.keyspace)
        rescue StandardErorr => exception
          drop_keyspace!(env)
          raise exception
        end
      end

      def create_keyspace_statement(config)
        validate_config(config)
        <<-CQL.strip_heredoc
          CREATE KEYSPACE #{config.keyspace}
          WITH replication = {
            'class': '#{config.replication['class']}',
            #{replication_options_statement(config)}
          }
        CQL
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
          raise Errors::MissingConfigurationError.new("Configuration of 'keyspace' is required in config/cassandra.yml, but none is defined.")
        elsif config_requires_replication?(config) && !config_includes_replication?(config)
          raise Errors::MissingConfigurationError.new("Configuration for 'replication' is required in config/cassandra.yml, but none is defined.")
        end
        true
      end

      def config_requires_replication?(config)
        config.replication['class'] == 'SimpleStrategy'
      end

      def config_includes_replication?(config)
        config.replication &&
        config.replication['class'] &&
        config.replication['replication_factor']
      end

      def replication_options_statement(config)
        if config.replication['class'] == "SimpleStrategy"
         "'replication_factor': #{config.replication['replication_factor']}"
        elsif config.replication['class'] == "NetworkTopologyStrategy"
          config.replication.reject{ |k,v| k == 'class' }.map { |k,v| "'#{k}': #{v}" }.join(", ")
        end
      end
    end
  end
end
