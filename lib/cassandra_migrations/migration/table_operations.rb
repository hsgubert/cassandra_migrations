# encoding: utf-8

require 'cassandra_migrations/migration/create_table_helper'

module CassandraMigrations
  class Migration
    
    # Module grouping methods used in migrations to make table operations like:
    # - creating tables
    # - dropping tables
    # - renaming tables
    module TableOperations
  
      # Creates a new table in the keyspace
      #
      # options:
      # - :primary_keys: single value or array (for compound primary keys). If
      # not defined, some column must be chosen as primary key in the table definition. 
      
      def create_table(table_name, options = {})
        create_table_helper = CreateTableHelper.new
        create_table_helper.define_primary_keys(options[:primary_keys]) if options[:primary_keys]

        yield create_table_helper if block_given?

        announce_operation "create_table(#{table_name})"

        create_cql =  "CREATE TABLE #{table_name} ("
        create_cql << create_table_helper.to_cql
        create_cql << ")"
        
        announce_suboperation create_cql
        
        execute create_cql
      end
      
      def drop_table(table_name)
        announce_operation "drop_table(#{table_name})"
        drop_cql =  "DROP TABLE #{table_name}"
        announce_suboperation drop_cql
        
        execute drop_cql
      end
    end
  end
end
