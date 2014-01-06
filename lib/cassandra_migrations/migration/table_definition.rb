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
          raise Errors::MigrationDefinitionError, 'No columns defined for table.'
        end

        if !@primary_keys.empty?
          cql << "PRIMARY KEY(#{@primary_keys.join(', ')})"
        else
          raise Errors::MigrationDefinitionError, 'No primary key defined.'
        end
        
        cql.join(', ')
      end
      
      def to_add_column_cql
        cql = ""

        if @columns_name_type_hash.size == 1
          cql = "#{@columns_name_type_hash.keys.first} #{@columns_name_type_hash.values.first}"
        elsif @columns_name_type_hash.empty?
          raise Errors::MigrationDefinitionError, 'No column to add.'
        else
          raise Errors::MigrationDefinitionError, 'Only one column can be added at once.'
        end
        
        cql
      end
      
      def boolean(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:boolean, options)
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def integer(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:integer, options) 
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def float(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:float, options) 
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def double(column_name, options={})
        options[:limit] = 8
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:float, options) 
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def string(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:string, options)
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def text(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:text, options)
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def datetime(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:datetime, options)
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def timestamp(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:timestamp, options)
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def uuid(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:uuid, options)
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def timeuuid(column_name, options={})
        @columns_name_type_hash[column_name.to_sym] = column_type_for(:timeuuid, options)
        define_primary_keys(column_name) if options[:primary_key]
      end
      
      def list(column_name, options={})
        type = options[:type]
        if type.nil?
          raise Errors::MigrationDefinitionError, 'A list must define a collection type.'
        elsif !self.respond_to?(type)
          raise Errors::MigrationDefinitionError, "Type '#{type}' is not valid for cassandra migration."
        end
        if options[:primary_key]
          raise Errors::MigrationDefinitionError, 'A collection cannot be used as a primary key.'
        end
        @columns_name_type_hash[column_name.to_sym] = :"list<#{column_type_for(type)}>"
      end
      
      def set(column_name, options={})
        type = options[:type]
        if type.nil?
          raise Errors::MigrationDefinitionError, 'A set must define a collection type.'
        elsif !self.respond_to?(type)
          raise Errors::MigrationDefinitionError, "Type '#{type}' is not valid for cassandra migration."
        end
        if options[:primary_key]
          raise Errors::MigrationDefinitionError, 'A collection cannot be used as a primary key.'
        end
        @columns_name_type_hash[column_name.to_sym] = :"set<#{column_type_for(type)}>"
      end
      
      def map(column_name, options={})
        key_type, value_type = options[:key_type], options[:value_type]
        [key_type, value_type].each_with_index do |type, index|
          if type.nil?
            raise Errors::MigrationDefinitionError, "A map must define a #{index = 0 ? 'key' : 'value'} type." 
          elsif !self.respond_to?(type)
            raise Errors::MigrationDefinitionError, "Type '#{type}' is not valid for cassandra migration."
          end
        end

        if options[:primary_key]
          raise Errors::MigrationDefinitionError, 'A collection cannot be used as a primary key.'
        end
        @columns_name_type_hash[column_name.to_sym] = :"map<#{column_type_for(key_type)},#{column_type_for(value_type)}>"        
      end
      
      def define_primary_keys(*keys)
        if !@primary_keys.empty?
          raise Errors::MigrationDefinitionError, 'Primary key defined twice for the same table.'
        end
        
        @primary_keys = keys.flatten
      end
      
      private
      
        def column_type_for(ruby_type, options={})
          limit = options[:limit]
          case ruby_type
            when :boolean, :text, :timestamp, :uuid, :timeuuid
              ruby_type
            when :integer
              if limit.nil? || limit == 4
                :int
              elsif limit == 8
                :bigint
              else
                raise Errors::MigrationDefinitionError, ':limit option should be 4 or 8 for integers.'
              end
            when :float
              if limit.nil? || limit == 4
                :float
              elsif limit == 8
                :double
              else
                raise Errors::MigrationDefinitionError, ':limit option should be 4 or 8 for floats.'
              end
            when :string
              :varchar
            when :datetime
              :timestamp
          end
        end
    end
  end
end
