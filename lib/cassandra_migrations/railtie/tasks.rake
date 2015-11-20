# encoding : utf-8

namespace :cassandra do

  task :start do
    CassandraMigrations::Cassandra.start!
  end

  desc 'Create the keyspace in config/cassandra.yml for the current environment'
  task :create do
    begin
      CassandraMigrations::Cassandra.start!
      puts "Keyspace #{CassandraMigrations::Config.keyspace} already exists!"
    rescue CassandraMigrations::Errors::UnexistingKeyspaceError
      CassandraMigrations::Cassandra.create_keyspace!(Rails.env)
      puts "Created keyspace #{CassandraMigrations::Config.keyspace}"
    end
  end

  desc 'Drop keyspace in config/cassandra.yml for the current environment'
  task :drop do
    begin
      CassandraMigrations::Cassandra.drop_keyspace!(Rails.env)
      puts "Dropped keyspace #{CassandraMigrations::Config.keyspace}"
    rescue CassandraMigrations::Errors::UnexistingKeyspaceError
      puts "Keyspace #{CassandraMigrations::Config.keyspace} does not exist... cannot be dropped"
    end
  end

  desc 'Migrate the keyspace to the latest version'
  task :migrate => :start do
    migrations_up_count = CassandraMigrations::Migrator.up_to_latest!

    if migrations_up_count == 0
      puts "Already up-to-date"
    else
      puts "Migrated #{migrations_up_count} version(s) up."
    end
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n)'
  task :rollback => :start do
    steps = (ENV['STEP'] ? ENV['STEP'].to_i : 1)

    migrations_down_count = CassandraMigrations::Migrator.rollback!(steps)

    if steps == migrations_down_count
      puts "Rolled back #{steps} version(s)."
    else
      puts "Asked to rollback #{steps} version(s). Only achieved #{migrations_down_count}."
    end
  end

  namespace :migrate do
    desc 'Resets and prepares cassandra database (all data will be lost)'
    task :reset do
      Rake::Task['cassandra:drop'].execute
      Rake::Task['cassandra:create'].execute
      Rake::Task['cassandra:migrate'].execute
    end
  end

  task :setup do
    puts "DEPRECATION WARNING: `cassandra:setup` rake task has been deprecated, use `cassandra:migrate:reset` instead"
    Rake::Task['cassandra:create'].execute
    Rake::Task['cassandra:migrate'].execute
  end

  namespace :test do
    desc 'Load the development schema in to the test keyspace via a full reset'
    task :prepare do
      Rails.env = 'test'
      Rake::Task['cassandra:migrate:reset'].execute
    end
  end

  desc 'Retrieves the current schema version number'
  task :version => :start do
    puts "Current version: #{CassandraMigrations::Migrator.read_current_version}"
  end

  task

end
