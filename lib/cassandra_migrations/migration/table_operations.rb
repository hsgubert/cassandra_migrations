# encoding: utf-8

require 'cassandra_migrations/migration/create_table_helper'

module CassandraMigrations
  class Migration
    
    # Module grouping methods used in migrations to make table operations like:
    # - creating tables
    # - dropping tables
    # - renaming tables
    module TableOperations
  
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
        
    end
  end
end
