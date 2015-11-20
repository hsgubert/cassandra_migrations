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
    puts ''
    puts 'Your steps from here are:'.green
    puts '  1. configure '.green + 'config/cassandra.yml'.red
    puts '  2. run '.green + 'rake cassandra:create'.red + ' and try starting your application'.green
    puts '  3. create your first migration with '.green + 'rails g cassandra_migration'.red
    puts '  4. apply your migration with '.green + 'rake cassandra:migrate'.red
    puts '  5. run '.green + 'rake cassandra:test:prepare'.red + ' and start testing'.green
    puts '  6. have lots of fun!'.green.blink
  end
end
