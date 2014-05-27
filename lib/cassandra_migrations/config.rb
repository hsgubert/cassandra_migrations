# encoding: utf-8

module CassandraMigrations
  module Config

    FIELDS = %w(host port keyspace replication)

    Configuration = Struct.new(*FIELDS.map(&:to_sym))

    mattr_writer :configurations

    def self.configurations
      @configurations || load_config
    end

    def self.method_missing(method_sym, *arguments, &block)
      load_config unless configurations
      self.configurations[Rails.env].send(method_sym)
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
