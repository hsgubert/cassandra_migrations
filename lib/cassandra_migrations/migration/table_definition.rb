# encoding: utf-8

module CassandraMigrations
  class Migration

    # Used to define a table in a migration of table creation or to
    # add columns to an existing table.
    #
    # An instance of this class is passed to the block of the method
    # +create_table+, available on every migration.
    #
    # This class is also internally used in the method +add_column+.
    
    class TableDefinition

      def initialize()
        @columns_name_type_hash = {}
        @primary_keys = []
      end
      
      def to_create_cql
        cql = []

        if !@columns_name_type_hash.empty?
          @columns_name_type_hash.each do |column_name, type|
            cql << "#{column_name} #{type}"
          end
        else
          raise Errors::MigrationDefinitionError('No columns defined for table.')
        end

        if !@primary_keys.empty?
          cql << "PRIMARY KEY(#{@primary_keys.join(', ')})"
        else
          raise Errors::MigrationDefinitionError('No primary key defined.')
        end
        
        cql.join(', ')
      end
      
      def to_add_column_cql
        cql = ""

        if @columns_name_type_hash.size == 1
          cql = "#{@columns_name_type_hash.keys.first} #{@columns_name_type_hash.values.first}"
        elsif @columns_name_type_hash.empty?
          raise Errors::MigrationDefinitionError('No column to add.')
        else
          raise Errors::MigrationDefinitionError('Only one column can be added at once.')
        end
        
        cql
      end
      
      def boolean(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = :boolean
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def integer(column_name, options={})
        if options[:limit].nil? || options[:limit] == 4
          @columns_name_type_hash[column_name.to_sym] = :int
        elsif options[:limit] == 8
          @columns_name_type_hash[column_name.to_sym] = :bigint
        else
          raise Errors::MigrationDefinitionError(':limit option should be 4 or 8 for integers.')
        end 
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def float(column_name, options={})
        if options[:limit].nil? || options[:limit] == 4
          @columns_name_type_hash[column_name.to_sym] = :float
        elsif options[:limit] == 8
          @columns_name_type_hash[column_name.to_sym] = :double
        else
          raise Errors::MigrationDefinitionError(':limit option should be 4 or 8 for floats.')
        end
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def string(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = :varchar
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def text(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = :text
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def datetime(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = :timestamp
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def timestamp(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = :timestamp
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def define_primary_keys(*keys)
        if !@primary_keys.empty?
          raise Errors::MigrationDefinitionError('Primary key defined twice for the same table.')
        end
        
        @primary_keys = keys.flatten
      end
    end
  end
end
