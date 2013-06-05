# encoding: utf-8

module CassandraMigrations
  module Cassandra
    class QueryResult
      
      def initialize(cql_query_result)
        @cql_query_result = cql_query_result
      end
      
      # We don't want to flood the console or the log with an inspection of
      # a lot of loaded data
      def inspect
        "#<CassandraMigrations::Cassandra::QueryResult:#{object_id}>"
      end

      # Returns {'column_name' => :column_type} hash
      def metadata
        hash = {}
        @cql_query_result.metadata.each do |column_metadata|
          hash[column_metadata.column_name] = column_metadata.type   
        end
        hash
      end

      # Delegates all other method calls to the lower level query result (Cql::Client::QueryResult)
      def method_missing(name, *args, &block)
        @cql_query_result.send(name, *args, &block)
      end

    end
  end
end
