class CassandraConfigurationGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', File.dirname(__FILE__))

  # Creates configuration file and migration directory
  #
  # Any public method in the generator is run automatically when
  # the generator is run. To understand fully see
  # http://asciicasts.com/episodes/218-making-generators-in-rails-3

  def generate_configuration
    require 'fileutils'
    require 'colorize'

    # create cassandra.yaml
    if File.exists?(File.expand_path('config/cassandra.yml'))
      puts "[skip] 'config/cassandra.yml' already exists".yellow
    else
      puts "[new] creating 'config/cassandra.yml' (please update with your own configurations!)".green
      template "cassandra.yml", "config/cassandra.yml"
    end

    # create db/cassandra_migrations
    if File.exists?(File.expand_path('db/cassandra_migrate'))
      puts "[skip] 'db/cassandra_migrate' already exists".yellow
    else
      puts "[new] creating 'db/cassandra_migrate' directory".green
      FileUtils.mkdir(File.expand_path('db/cassandra_migrate'))
    end

    puts '[done]'.green
  end
end
