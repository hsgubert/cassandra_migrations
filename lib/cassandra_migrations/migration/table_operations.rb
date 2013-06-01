# encoding: utf-8

require 'cassandra_migrations/migration/table_definition'

module CassandraMigrations
  class Migration
    
    # Module grouping methods used in migrations to make table operations like:
    # - creating tables
    # - dropping tables
    module TableOperations
  
      # Creates a new table in the keyspace
      #
      # options:
      # - :primary_keys: single value or array (for compound primary keys). If
      # not defined, some column must be chosen as primary key in the table definition. 
      
      def create_table(table_name, options = {})
        table_definition = TableDefinition.new
        table_definition.define_primary_keys(options[:primary_keys]) if options[:primary_keys]

        yield table_definition if block_given?

        announce_operation "create_table(#{table_name})"

        create_cql =  "CREATE TABLE #{table_name} ("
        create_cql << table_definition.to_create_cql
        create_cql << ")"
        
        announce_suboperation create_cql
        
        execute create_cql
      end
      
      # Drops a table
      def drop_table(table_name)
        announce_operation "drop_table(#{table_name})"
        drop_cql =  "DROP TABLE #{table_name}"
        announce_suboperation drop_cql
        
        execute drop_cql
      end
    end
  end
end
