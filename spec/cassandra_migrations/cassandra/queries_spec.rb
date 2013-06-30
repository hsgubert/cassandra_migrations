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
      
      TestQueryExecutor.write!('people',
        :name => 'John',
        :age => 24,
        :height_in_meters => 1.83,
        :birth_time => Time.new(1989, 05, 27, 8, 50, 25, 0)
      )
    end
  end
  
  describe '.update!' do
    it 'should update some record values' do
      TestQueryExecutor.should_receive(:execute).with(
        "UPDATE people SET height_in_meters = 1.93, birth_time = '1989-05-28 08:50:25+0000' WHERE name = 'John'"
      )
      
      TestQueryExecutor.update!('people', "name = 'John'",
        :height_in_meters => 1.93,
        :birth_time => Time.new(1989, 05, 28, 8, 50, 25, 0)
      )
    end
  end
  
  describe '.select' do
    it 'should make select query with WHERE, ORDER BY and LIMIT' do
      TestQueryExecutor.should_receive(:execute).with(
        "SELECT * FROM people WHERE name = 'John' ORDER BY birth_time LIMIT 200"
      )
      
      TestQueryExecutor.select('people', 
        :selection => "name = 'John'",
        :order_by => 'birth_time',
        :limit => 200
      )
    end
    
    it 'should allow to specify projection (columns loaded)' do
      TestQueryExecutor.should_receive(:execute).with(
        "SELECT age, birth_time FROM people WHERE name = 'John'"
      )
      
      TestQueryExecutor.select('people', 
        :selection => "name = 'John'",
        :projection => 'age, birth_time'
      )
    end
  end  
end
