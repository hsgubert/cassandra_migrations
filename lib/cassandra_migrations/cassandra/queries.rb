# encoding: utf-8

module CassandraMigrations
  module Cassandra
    module Queries
  
      def write!(table, hash)
        columns = []
        values = []
        
        hash.each do |k,v| 
          columns << k.to_s
          
          if v.respond_to?(:strftime)
            values << "'#{v.strftime('%Y-%m-%d %H:%M:%S%z')}'"
          elsif v.is_a?(String)
            values << "'#{v}'"          
          else
            values << v.to_s
          end
        end
    
        execute("INSERT INTO #{table} (#{columns.join(', ')}) VALUES (#{values.join(', ')})")
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
      
    end
  end
end
