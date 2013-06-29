# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Cassandra::Queries do
  
  class TestQueryExecutor
    extend CassandraMigrations::Cassandra::Queries
  end
  
  describe '.write!' do
    it 'should insert a record into the specified table' do
      TestQueryExecutor.should_receive(:execute).with(
        "INSERT INTO people (name, age, height_in_meters, birth_time) VALUES ('John', 24, 1.83, '1989-05-27 08:50:25+0000')"
      )
      
      TestQueryExecutor.write!('people', {
        :name => 'John',
        :age => 24,
        :height_in_meters => 1.83,
        :birth_time => Time.new(1989, 05, 27, 8, 50, 25, 0)
      })
    end
  end
  
end
