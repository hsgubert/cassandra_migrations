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
        options[:secondary_options] ||= {}

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

        #Secondary options
        if options[:page_size]
          options[:secondary_options][:page_size] = options[:page_size]
        end

        if options[:consistency]
          options[:secondary_options][:consistency] = options[:consistency]
        end

        if options[:trace]
          options[:secondary_options][:trace] = options[:trace]
        end

        if options[:timeout]
          options[:secondary_options][:timeout] = options[:timeout]
        end

        if options[:serial_consistency]
          options[:secondary_options][:serial_consistency] = options[:serial_consistency]
        end

        if options[:paging_state]
          options[:secondary_options][:paging_state] = options[:paging_state]
        end

        if options[:arguments]
          options[:secondary_options][:arguments] = options[:arguments]
        end

        if options[:secondary_options].length > 0
          execute(query_string, options[:secondary_options])
        else
          execute(query_string)
        end
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
        column_type = client.execute("SELECT type FROM system_schema.columns WHERE keyspace_name = '#{client.keyspace}' AND table_name = '#{table}' AND column_name = '#{column}'").first['type']
        column_type.split("<").first.to_sym
      end

      def to_cql_value(column, value, table, options={})
        operator = options[:operations] ? options[:operations][column.to_sym] : nil
        operation = operator ? "#{column} #{operator} " : ''

        if value.respond_to?(:strftime)
          datetime_to_cql(value)
        elsif value.is_a?(String)
          string_to_cql(value)
        elsif value.is_a?(Array)
          array_value_to_cql(column, value, table, operation)
        elsif value.is_a?(Hash)
          hash_to_cql(value, operation)
        else
          value = value.to_s
          if value == ""
            value = 'null'
          else
            value = value.gsub("'", "''")
          end
        end
      end

      def string_to_cql(value)
        "'#{value.gsub("'", "''")}'"
      end

      def datetime_to_cql(value)
        "'#{value.strftime('%Y-%m-%d %H:%M:%S%z')}'"
      end

      def array_value_to_cql(column, value, table, operation)
        type = get_column_type(table, column)
        values = %[#{value.map { |v| to_cql_value(nil, v, nil) } * ', '}]

        if type && type == :list
          %[#{operation}[#{values}]]
        else # it must be a set!
          %[#{operation}{#{values}}]
        end
      end

      def hash_to_cql(value, operation)
        "#{operation}{ #{value.reduce([]) {|sum, (k, v)| sum << "'#{k}': #{to_cql_value(nil, v, nil)}" }.join(", ") } }"
      end

    end
  end
end
