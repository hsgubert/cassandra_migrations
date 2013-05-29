# encoding : utf-8

module CassandraMigrations

  namespace :cassandra do

    task :start do
      Cassandra.start!
    end

    desc 'Create the keyspace in config/cassandra.yml for the current environment'
    task :create do
      begin
        Cassandra.start!
        puts "Keyspace #{Cassandra.config['keyspace']} already exists!"
      rescue Cassandra::Errors::UnexistingKeyspaceError
        Cassandra.create_keyspace!
        puts "Created keyspace #{Cassandra.config['keyspace']}"
      end
    end

    desc 'Drop keyspace in config/cassandra.yml for the current environment'
    task :drop do
      begin
        Cassandra.drop_keyspace!
        puts "Dropped keyspace #{Cassandra.config['keyspace']}"
      rescue Cassandra::Errors::UnexistingKeyspaceError
        puts "Keyspace #{Cassandra.config['keyspace']} does not exist... cannot be dropped"
      end
    end

    desc 'Migrate the keyspace to the latest version'
    task :migrate => :start do
      migrations_up_count = Cassandra::Migrator.up_to_latest!

      if migrations_up_count == 0
        puts "Already up-to-date"
      else
        puts "Migrated #{migrations_up_count} version(s) up."
      end
    end

    desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n)'
    task :rollback => :start do
      steps = (ENV['STEP'] ? ENV['STEP'].to_i : 1)

      migrations_down_count = Cassandra::Migrator.rollback!(steps)

      if steps == migrations_down_count
        puts "Rolled back #{steps} version(s)."
      else
        puts "Asked to rollback #{steps} version(s). Only achieved #{migrations_down_count}."
      end
    end

    desc 'Resets and prepares cassandra database (all data will be lost)'
    task :setup do
      Rake::Task['cassandra:drop'].execute
      Rake::Task['cassandra:create'].execute
      Rake::Task['cassandra:migrate'].execute
    end

    namespace :test do
      desc 'Load the development schema in to the test keyspace'
      task :prepare do
        Rails.env = 'test'
        Rake::Task['cassandra:setup'].execute
      end
    end

    desc 'Retrieves the current schema version number'
    task :version => :start do
      puts "Current version: #{Cassandra::Migrator.read_current_version}"
    end

  end
end
