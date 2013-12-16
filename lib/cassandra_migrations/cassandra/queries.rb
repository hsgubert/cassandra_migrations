# encoding: utf-8

module CassandraMigrations
  module Cassandra
    module Queries
  
      def write!(table, value_hash, options={})
        columns = []
        values = []
        
        value_hash.each do |column, value| 
          columns << column.to_s
          values << to_cql_value(column, value, table, options)
        end
    
        query = "INSERT INTO #{table} (#{columns.join(', ')}) VALUES (#{values.join(', ')})"
        
        if options[:ttl]
          query += " USING TTL #{options[:ttl]}"
        end
        
        execute(query)
      end
      
      def update!(table, selection, value_hash, options={})
        set_terms = []
        value_hash.each do |column, value| 
          set_terms << "#{column} = #{to_cql_value(column, value, table, options)}"
        end
        
        query = "UPDATE #{table}"
        
        if options[:ttl]
          query += " USING TTL #{options[:ttl]}"
        end
        
        query += " SET #{set_terms.join(', ')} WHERE #{selection}"
        
        execute(query)
      end
      
      def select(table, options={})
        query_string = "SELECT #{options[:projection] || '*'} FROM #{table}"
        
        if options[:selection]
          query_string << " WHERE #{options[:selection]}"
        end
        
        if options[:order_by]
          query_string << " ORDER BY #{options[:order_by]}"
        end
        
        if options[:limit]
          query_string << " LIMIT #{options[:limit]}"
        end
        
        if options[:allow_filtering]
          query_string << " ALLOW FILTERING"
        end
    
        execute(query_string)
      end
      
      def delete!(table, selection, options={})
        options[:projection] = options[:projection].to_s + ' ' if options[:projection]
        execute("DELETE #{options[:projection]}FROM #{table} WHERE #{selection}")
      end
      
      def truncate!(table)
        execute("TRUNCATE #{table}")
      end
      
    private
    
      def get_column_type(table, column)
        column_info = client.execute("SELECT VALIDATOR FROM system.schema_columns WHERE keyspace_name = '#{client.keyspace}' AND columnfamily_name = '#{table}' AND column_name = '#{column}'")
        raw_type = column_info.first['validator']
        
        case
          when raw_type.include?('SetType'); :set
          when raw_type.include?('ListType'); :list
          when raw_type.include?('MapType'); :map
          when raw_type.include?('BooleanType'); :boolean
          when raw_type.include?('FloatType'); :float
          when raw_type.include?('Int32Type'); :int
          when raw_type.include?('DateType'); :timestamp
          when raw_type.include?('UTF8Type'); :string
          when raw_type.include?('BytesType'); :blob
          when raw_type.include?('UUIDType'); :uuid
          when raw_type.include?('DoubleType'); :double
          when raw_type.include?('InetAddressType'); :inet
          when raw_type.include?('AsciiType'); :ascii
          when raw_type.include?('LongType'); :bigint          
          when raw_type.include?('DecimalType'); :decimal   
          when raw_type.include?('TimeUUIDType'); :timeuuid    
        end
      end
    
      def to_cql_value(column, value, table, options={})
        operator = options[:operations] ? options[:operations][column.to_sym] : nil
        operation = operator ? "#{column} #{operator} " : ''
        
        if value.respond_to?(:strftime)
          "'#{value.strftime('%Y-%m-%d %H:%M:%S%z')}'"
        elsif value.is_a?(String)
          "'#{value}'"   
        elsif value.is_a?(Array)
          type = get_column_type(table, column)
          values = %[#{value.map { |v| to_cql_value(nil, v, nil) } * ', '}] 
          
          if type && type == :list
            %[#{operation}[#{values}]]
          else # it must be a set!
            %[#{operation}{#{values}}]
          end
        elsif value.is_a?(Hash)
          "#{operation}{ #{value.reduce([]) {|sum, (key, value)| sum << "'#{key}': '#{value}'" }.join(", ") } }"
        else
          value.to_s
        end
      end
    end
  end
end
