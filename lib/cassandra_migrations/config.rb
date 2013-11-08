# encoding: utf-8

module CassandraMigrations
  module Config
  
    mattr_accessor :config
    
    def self.method_missing(method_sym, *arguments, &block)
      load_config unless config    
      config[method_sym.to_s]
    end
    
  private

    def self.load_config
      begin
        self.config = YAML.load(ERB.new(File.new(Rails.root.join("config", "cassandra.yml")).read).result)[Rails.env]
      
        if config.nil?
          raise Errors::MissingConfigurationError, "No configuration for #{Rails.env} environment! Complete your config/cassandra.yml."
        end
      rescue Errno::ENOENT
        raise Errors::MissingConfigurationError
      end
    end
  
  end
end
