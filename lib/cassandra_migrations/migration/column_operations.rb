# encoding: utf-8

require 'cassandra_migrations/migration/table_definition'

module CassandraMigrations
  class Migration
    
    # Module grouping methods used in migrations to make table operations like:
    # - adding/removing columns
    # - changing column types
    # - renaming columns
    module ColumnOperations
  
      # Adds a column to a table.
      #
      # options: same options you would pass to create a table with that column
      # (i.e. :limit might be applicable)
      
      def add_column(table_name, column_name, type, options = {})
        table_definition = TableDefinition.new
        
        if !table_definition.respond_to?(type)
          raise Errors::MigrationDefinitionError("Type '#{type}' is not valid for cassandra migration.")
        end

        table_definition.send(type, column_name, options)

        announce_operation "add_column(#{column_name}, #{type})"

        cql =  "ALTER TABLE #{table_name} ADD "
        cql << table_definition.to_add_column_cql
        announce_suboperation cql
        
        execute cql
      end
      
      # Removes a column from the table
      def remove_column(table_name, column_name)
        announce_operation "drop_table(#{table_name})"

        cql =  "ALTER TABLE #{table_name} DROP #{column_name}"
        announce_suboperation cql
        
        execute cql
      end
    end
  end
end
