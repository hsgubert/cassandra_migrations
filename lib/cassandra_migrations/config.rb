# encoding: utf-8

module CassandraMigrations
  module Config

    # See valid options at https://github.com/datastax/ruby-driver/blob/master/lib/cassandra.rb#L163
    CASSANDRA_CONNECTION_VALID_FIELDS = [
       :credentials, :auth_provider, :compression, :hosts, :logger, :port,
       :load_balancing_policy, :reconnection_policy, :retry_policy, :listeners,
       :consistency, :trace, :page_size, :compressor, :username, :password,
       :ssl, :server_cert, :client_cert, :private_key, :passphrase,
       :connect_timeout, :futures_factory]

    FIELDS = CASSANDRA_CONNECTION_VALID_FIELDS.map(&:to_s) + %w(keyspace replication)

    Configuration = Struct.new(*FIELDS.map(&:to_sym))

    mattr_writer :configurations

    def self.configurations
      @configurations || load_config
    end

    def self.method_missing(method_sym, *arguments, &block)
      load_config unless configurations
      self.configurations[Rails.env].send(method_sym)
    end

    def self.connection_config_for_env
      env_config = Hash[self.configurations[Rails.env].each_pair.to_a]

      # support for old configuration param :port (singular)
      if env_config.include?(:port)
        env_config[:ports] = [env_config[:port]]
      end

      env_config.keep_if do |k,v|
        CASSANDRA_CONNECTION_VALID_FIELDS.include?(k) && v
      end

      Hash[self.configurations[Rails.env].each_pair.to_a].keep_if do |k,v|
        CASSANDRA_CONNECTION_VALID_FIELDS.include?(k) && v
      end
    end

  private

    def self.load_config
      begin
        configs = YAML.load(ERB.new(File.new(Rails.root.join("config", "cassandra.yml")).read).result)
        configurations = Hash[configs.map {|env, config| [env, Configuration.new(*(FIELDS.map {|k| config[k]}))]}]
        if configurations[Rails.env].nil?
          raise Errors::MissingConfigurationError, "No configuration for #{Rails.env} environment! Complete your config/cassandra.yml."
        end
        configurations
      rescue Errno::ENOENT
        raise Errors::MissingConfigurationError
      end
    end

  end
end
