# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Cassandra::Queries do

  class TestQueryExecutor
    extend CassandraMigrations::Cassandra::Queries

    def self.column_type=(column_type)
      @column_type = column_type
    end

    private

      def self.get_column_type(table, column)
        @column_type
      end
  end

  describe '.write!' do
    it 'should insert a record into the specified table' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "INSERT INTO people (name, age, height_in_meters, birth_time) VALUES ('John', 24, 1.83, '1989-05-27 08:50:25+0000')"
      )

      TestQueryExecutor.write!('people',
        :name => 'John',
        :age => 24,
        :height_in_meters => 1.83,
        :birth_time => Time.new(1989, 05, 27, 8, 50, 25, 0)
      )
    end

    it 'should insert a record into the specified table with a nil value for non-string type' do
      allow(TestQueryExecutor).to receive(:execute).with(
      "INSERT INTO people (name, age, height_in_meters, birth_time) VALUES ('John', 24, 1.83, null)"
      )

      TestQueryExecutor.write!('people',
      :name => 'John',
      :age => 24,
      :height_in_meters => 1.83,
      :birth_time => nil
      )
    end

    it 'should insert a record into the specified table with a string value containing a single quote' do
      allow(TestQueryExecutor).to receive(:execute).with(
      "INSERT INTO people (name, age, height_in_meters, birth_time) VALUES ('John''s name', 24, 1.83, null)"
      )

      TestQueryExecutor.write!('people',
      :name => "John's name",
      :age => 24,
      :height_in_meters => 1.83,
      :birth_time => nil
      )
    end

    it 'should set record TTL' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "INSERT INTO people (name) VALUES ('John') USING TTL 3600"
      )

      TestQueryExecutor.write!('people', {:name => 'John'}, :ttl => 3600)
    end

    context 'when dealing with collections' do

      it 'should handle setting a set collection column value' do
        TestQueryExecutor.column_type = :set

        allow(TestQueryExecutor).to receive(:execute).with(
          "INSERT INTO people (friends) VALUES ({'John', 'Ringo', 'Paul', 'George'})"
        )

        TestQueryExecutor.write!('people', {friends: ['John', 'Ringo', 'Paul', 'George']})
      end

      it 'should handle setting a list collection column value' do
        TestQueryExecutor.column_type = :list

        allow(TestQueryExecutor).to receive(:execute).with(
          "INSERT INTO people (friends) VALUES (['John', 'Ringo', 'Paul', 'George'])"
        )

        TestQueryExecutor.write!('people', {friends: ['John', 'Ringo', 'Paul', 'George']})
      end

      it 'should handle setting a map collection column value' do
        TestQueryExecutor.column_type = :map

        allow(TestQueryExecutor).to receive(:execute).with(
          "INSERT INTO people (friends) VALUES ({ 'talent': 'John', 'drums': 'Ringo', 'voice': 'Paul', 'rhythm': 'George' })"
        )

        TestQueryExecutor.write!('people', {friends: {talent: 'John', drums: 'Ringo', voice: 'Paul', rhythm: 'George'}})
      end
    end
  end

  describe '.update!' do
    it 'should update some record values' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "UPDATE people SET height_in_meters = 1.93, birth_time = '1989-05-28 08:50:25+0000' WHERE name = 'John'"
      )

      TestQueryExecutor.update!('people', "name = 'John'",
        :height_in_meters => 1.93,
        :birth_time => Time.new(1989, 05, 28, 8, 50, 25, 0)
      )
    end

    it 'should update some record values with a nil value for a non-string type' do
      allow(TestQueryExecutor).to receive(:execute).with(
      "UPDATE people SET height_in_meters = null, birth_time = '1989-05-28 08:50:25+0000' WHERE name = 'John'"
      )

      TestQueryExecutor.update!('people', "name = 'John'",
      :height_in_meters => nil,
      :birth_time => Time.new(1989, 05, 28, 8, 50, 25, 0)
      )
    end

    it 'should set record TTL' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "UPDATE people USING TTL 3600 SET name = 'Johnny' WHERE name = 'John'"
      )

      TestQueryExecutor.update!('people', "name = 'John'", {:name => 'Johnny'}, :ttl => 3600)
    end

    context 'when dealing with collections' do

      it 'should handle setting a set collection column' do
        TestQueryExecutor.column_type = :set

        allow(TestQueryExecutor).to receive(:execute).with(
          "UPDATE people SET friends = {'John', 'Ringo', 'Paul', 'George'} WHERE name = 'Stuart'"
        )

        TestQueryExecutor.update!('people', "name = 'Stuart'", {friends: ['John', 'Ringo', 'Paul', 'George']})
      end

      it 'should handle adding elements to a set collection column' do
        TestQueryExecutor.column_type = :set

        allow(TestQueryExecutor).to receive(:execute).with(
          "UPDATE people SET friends = friends + {'John', 'Ringo', 'Paul', 'George'} WHERE name = 'Stuart'"
        )

        TestQueryExecutor.update!('people', "name = 'Stuart'",
                                            {friends: ['John', 'Ringo', 'Paul', 'George']},
                                            {operations: {friends: :+}})
      end

      it 'should handle removing elements from a set collection column' do
        TestQueryExecutor.column_type = :set

        allow(TestQueryExecutor).to receive(:execute).with(
          "UPDATE people SET friends = friends - {'John', 'Ringo', 'Paul', 'George'} WHERE name = 'Stuart'"
        )

        TestQueryExecutor.update!('people', "name = 'Stuart'",
                                            {friends: ['John', 'Ringo', 'Paul', 'George']},
                                            {operations: {friends: :-}})
      end

      it 'should handle setting a list collection column' do
        TestQueryExecutor.column_type = :list

        allow(TestQueryExecutor).to receive(:execute).with(
          "UPDATE people SET friends = ['John', 'Ringo', 'Paul', 'George'] WHERE name = 'Stuart'"
        )

        TestQueryExecutor.update!('people', "name = 'Stuart'", {friends: ['John', 'Ringo', 'Paul', 'George']})
      end

      it 'should handle adding elements to a list collection column' do
        TestQueryExecutor.column_type = :list

        allow(TestQueryExecutor).to receive(:execute).with(
          "UPDATE people SET friends = friends + ['John', 'Ringo', 'Paul', 'George'] WHERE name = 'Stuart'"
        )

        TestQueryExecutor.update!('people', "name = 'Stuart'",
                                            {friends: ['John', 'Ringo', 'Paul', 'George']},
                                            {operations: {friends: :+}})
      end

      it 'should handle removing elements from a list collection column' do
        TestQueryExecutor.column_type = :list

        allow(TestQueryExecutor).to receive(:execute).with(
          "UPDATE people SET friends = friends - ['John', 'Ringo', 'Paul', 'George'] WHERE name = 'Stuart'"
        )

        TestQueryExecutor.update!('people', "name = 'Stuart'",
                                            {friends: ['John', 'Ringo', 'Paul', 'George']},
                                            {operations: {friends: :-}})
      end

      it 'should handle setting a map collection column' do
        TestQueryExecutor.column_type = :map

        allow(TestQueryExecutor).to receive(:execute).with(
          "UPDATE people SET friends = { 'talent': 'John', 'drums': 'Ringo', 'voice': 'Paul', 'rhythm': 'George' } WHERE name = 'Stuart'"
        )

        TestQueryExecutor.update!('people', "name = 'Stuart'", {friends: {talent: 'John', drums: 'Ringo', voice: 'Paul', rhythm: 'George'}})
      end

      it 'should handle adding elements to a map collection column' do
        TestQueryExecutor.column_type = :map

        allow(TestQueryExecutor).to receive(:execute).with(
          "UPDATE people SET friends = friends + { 'talent': 'John', 'drums': 'Ringo', 'voice': 'Paul', 'rhythm': 'George' } WHERE name = 'Stuart'"
        )

        TestQueryExecutor.update!('people', "name = 'Stuart'",
                                            {friends: {talent: 'John', drums: 'Ringo', voice: 'Paul', rhythm: 'George'}},
                                            {operations: {friends: :+}})
      end

      it 'should handle removing elements from a map collection column' do
        TestQueryExecutor.column_type = :map

        allow(TestQueryExecutor).to receive(:execute).with(
          "DELETE friends['drums'] FROM people WHERE name = 'Stuart'"
        )

        TestQueryExecutor.delete!('people', "name = 'Stuart'", :projection => "friends['drums']")
      end
    end
  end

  describe '.select' do
    it 'should make select query with page_size' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "SELECT * FROM people WHERE name = 'John' ORDER BY birth_time", page_size: 200
      )

      TestQueryExecutor.select(
        'people',
        :selection => "name = 'John'",
        :order_by => 'birth_time',
        :page_size => 200
      )
    end

    it 'should make select query with page_size in secondary options hash' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "SELECT * FROM people WHERE name = 'John' ORDER BY birth_time", page_size: 200
      )

      TestQueryExecutor.select(
        'people',
        :selection => "name = 'John'",
        :order_by => 'birth_time',
        :secondary_options => {:page_size => 200}
      )
    end

    it 'should make select query with WHERE, ORDER BY and LIMIT' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "SELECT * FROM people WHERE name = 'John' ORDER BY birth_time LIMIT 200"
      )

      TestQueryExecutor.select('people',
        :selection => "name = 'John'",
        :order_by => 'birth_time',
        :limit => 200
      )
    end

    it 'should allow to specify projection (columns loaded)' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "SELECT age, birth_time FROM people WHERE name = 'John'"
      )

      TestQueryExecutor.select('people',
        :selection => "name = 'John'",
        :projection => 'age, birth_time'
      )
    end

    it 'should be able to query by uuid' do
      allow(TestQueryExecutor).to receive(:execute).with(
          'SELECT id FROM people WHERE id = 6bc939c2-838e-11e3-9706-4f2824f98172 ALLOW FILTERING'
      )

      TestQueryExecutor.select('people',
        :selection => 'id = 6bc939c2-838e-11e3-9706-4f2824f98172',
        :projection => 'id',
        :allow_filtering => true
      )
    end
  end

  describe '.delete!' do
    it 'should delete rows based in a selection' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "DELETE FROM people WHERE name IN ('John', 'Mike')"
      )

      TestQueryExecutor.delete!('people', "name IN ('John', 'Mike')")
    end

    it 'should delete column based in a selection and projection' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "DELETE age FROM people WHERE name IN ('John', 'Mike')"
      )

      TestQueryExecutor.delete!('people', "name IN ('John', 'Mike')", :projection => :age)
    end
  end

  describe '.truncate!' do
    it 'should clear table' do
      allow(TestQueryExecutor).to receive(:execute).with(
        "TRUNCATE people"
      )

      TestQueryExecutor.truncate!('people')
    end
  end
end
