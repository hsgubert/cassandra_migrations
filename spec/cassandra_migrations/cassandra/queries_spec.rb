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
    
    it 'should set record TTL' do
      TestQueryExecutor.should_receive(:execute).with(
        "INSERT INTO people (name) VALUES ('John') USING TTL 3600"
      )
      
      TestQueryExecutor.write!('people', {:name => 'John'}, :ttl => 3600)
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
  
  describe '.delete!' do
    it 'should delete rows based in a selection' do
      TestQueryExecutor.should_receive(:execute).with(
        "DELETE FROM people WHERE name IN ('John', 'Mike')"
      )
      
      TestQueryExecutor.delete!('people', "name IN ('John', 'Mike')")
    end
    
    it 'should delete column based in a selection and projection' do
      TestQueryExecutor.should_receive(:execute).with(
        "DELETE age FROM people WHERE name IN ('John', 'Mike')"
      )
      
      TestQueryExecutor.delete!('people', "name IN ('John', 'Mike')", :projection => :age)
    end
  end
  
  describe '.truncate!' do
    it 'should clear table' do
      TestQueryExecutor.should_receive(:execute).with(
        "TRUNCATE people"
      )
      
      TestQueryExecutor.truncate!('people')
    end
  end
end
