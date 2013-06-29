# encoding: utf-8

module CassandraMigrations
  module Cassandra
    module Queries
  
      def write!(table, value_hash)
        columns = []
        values = []
        
        value_hash.each do |column, value| 
          columns << column.to_s
          values << to_cql_value(value)
        end
    
        execute("INSERT INTO #{table} (#{columns.join(', ')}) VALUES (#{values.join(', ')})")
      end
      
      def update!(table, selection, value_hash)
        set_terms = []
        value_hash.each do |column, value| 
          set_terms << "#{column} = #{to_cql_value(value)}"
        end
        
        execute("UPDATE #{table} SET #{set_terms.join(', ')} WHERE #{selection}")
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
    
        execute(query_string)
      end
      
      def delete!(table, selection, options={})
        execute("DELETE #{options[:projection]} FROM #{table} WHERE #{selection}")
      end
      
      def truncate!(table)
        execute("TRUNCATE #{table}")
      end
      
    private
    
      def to_cql_value(value)
        if value.respond_to?(:strftime)
          "'#{value.strftime('%Y-%m-%d %H:%M:%S%z')}'"
        elsif value.is_a?(String)
          "'#{value}'"          
        else
          value.to_s
        end
      end
    end
  end
end
