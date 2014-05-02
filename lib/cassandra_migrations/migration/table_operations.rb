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
        table_definition.define_partition_keys(options[:partition_keys]) if options[:partition_keys]
        table_definition.define_options(options[:options]) if options[:options]

        yield table_definition if block_given?

        announce_operation "create_table(#{table_name})"

        create_cql =  "CREATE TABLE #{table_name} ("
        create_cql << table_definition.to_create_cql
        create_cql << ")"
        create_cql << table_definition.options
        
        announce_suboperation create_cql
        
        execute create_cql
      end
      
      def create_index(table_name, column_name, options = {})
        announce_operation "create_index(#{table_name})"
        create_index_cql = "CREATE INDEX #{options[:name]} ON #{table_name} (#{column_name})".squeeze(' ')
        announce_suboperation create_index_cql
        
        execute create_index_cql
      end
      
      # Drops a table
      def drop_table(table_name)
        announce_operation "drop_table(#{table_name})"
        drop_cql =  "DROP TABLE #{table_name}"
        announce_suboperation drop_cql
        
        execute drop_cql
      end
      
      def drop_index(table_or_index_name, column_name = nil, options = {})
        if column_name
          index_name = "#{table_or_index_name}_#{column_name}_idx"
        else
          index_name = table_or_index_name
        end
        drop_index_cql = "DROP INDEX #{options[:if_exists] ? 'IF EXISTS' : ''}#{index_name}"
        announce_suboperation drop_index_cql
        
        execute drop_index_cql        
      end

      def add_options(table_name, options)
        announce_operation "add_options_#{table_name}"
        add_options_cql = "ALTER TABLE #{properties_cql(options)}"
        announce_suboperation drop_index_cql

        execute add_options_cql
      end

    end
  end
end
