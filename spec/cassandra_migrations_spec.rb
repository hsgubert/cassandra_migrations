# encoding : utf-8
require 'spec_helper'

module CassandraMigrations

  # Temporarily monkey path Migration to allow for testing generated CQL
  # and suppress announcements
  class Migration
    attr_reader :cql

    def execute(cql)
      @cql = cql
    end

    private
      def announce_migration(message); end
      def announce_operation(message); end
      def announce_suboperation(message); end
  end
end

describe CassandraMigrations do

  it "should define modules" do
    expect(defined?(CassandraMigrations)).to be_truthy
    expect(defined?(CassandraMigrations::Railtie)).to be_truthy
    expect(defined?(CassandraMigrations::Cassandra)).to be_truthy
    expect(defined?(CassandraMigrations::Errors)).to be_truthy
    expect(defined?(CassandraMigrations::Migration)).to be_truthy
    expect(defined?(CassandraMigrations::Migrator)).to be_truthy
    expect(defined?(CassandraMigrations::Config)).to be_truthy
  end

  context 'a migration' do
    before do
      require_relative 'fixtures/migrations/migrations'
    end

    context 'without a primary key' do
      before do
        @migration = WithoutAPrimaryKey.new
      end

      it 'should be invalid' do
        expect { @migration.up }.to raise_error(CassandraMigrations::Errors::MigrationDefinitionError, /No primary key defined./)
      end
    end

    context 'that is valid' do
      before do
        @migration = CreateKitchenSink.new
      end

      it 'should have a name' do
        expect(@migration.send(:name)).to eq('CreateKitchenSink')
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE kitchen_sink (id uuid, a_string varchar, a_timestamp timestamp, a_float float, a_list_of_strings list<varchar>, PRIMARY KEY(id))"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'with a list collection column declaration' do
      before do
        @migration = CollectionsListMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, list_1 list<varchar>, PRIMARY KEY(id))"
        expect(@migration.cql).to eq(expected_cql)
      end

      context 'using invalid types' do
        before do
          @migration = BadCollectionsListMigration.new
        end

        it 'should be invalid' do
          expect { @migration.up }.to raise_error(CassandraMigrations::Errors::MigrationDefinitionError, /Type 'chupacabra' is not valid for cassandra migration./)
        end
      end
    end

    context 'with a set collection column declaration' do
      before do
        @migration = CollectionsSetMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, set_2 set<float>, PRIMARY KEY(id))"
        expect(@migration.cql).to eq(expected_cql)
      end

      context 'using invalid types' do
        before do
          @migration = BadCollectionsSetMigration.new
        end

        it 'should be invalid' do
          expect { @migration.up }.to raise_error(CassandraMigrations::Errors::MigrationDefinitionError, /Type 'narwhal' is not valid for cassandra migration./)
        end
      end
    end

    context 'with a map collection column declaration' do
      before do
        @migration = CollectionsMapMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, map_1 map<varchar,float>, PRIMARY KEY(id))"
        expect(@migration.cql).to eq(expected_cql)
      end

      context 'using invalid types' do
        before do
          @migration = BadCollectionsMapMigration.new
        end

        it 'should be invalid' do
          expect { @migration.up }.to raise_error(CassandraMigrations::Errors::MigrationDefinitionError, /Type 'unicorns' is not valid for cassandra migration./)
        end
      end
    end

    context 'with an secondary index definition' do
      before do
        @migration = MigrationWithSecondaryIndex.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE INDEX ON with_indexes (a_string)"
        expect(@migration.cql).to eq(expected_cql)
      end

      it 'should produce a valid CQL drop statement' do
        @migration.down
        expected_cql = "DROP INDEX with_indexes_a_string_idx"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'with a named secondary index definition' do
      before do
        @migration = MigrationWithANamedSecondaryIndex.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE INDEX by_another_string ON with_indexes (another_string)"
        expect(@migration.cql).to eq(expected_cql)
      end

      it 'should produce a valid CQL drop statement' do
        @migration.down
        expected_cql = "DROP INDEX by_another_string"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'that has composite primary key' do
      before do
        @migration = CompositePrimaryKey.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE composite_primary_key (id uuid, a_string varchar, PRIMARY KEY(id, a_string))"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'that has composite partition key' do
      before do
        @migration = CompositePartitionKey.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE composite_partition_key (id uuid, a_string varchar, a_timestamp timestamp, PRIMARY KEY((id, a_string), a_timestamp))"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'with a float column declaration with an invalid precision' do
      before do
        @migration = BadFloatColumnDeclarationMigration.new
      end

      it 'should be invalid' do
        expect { @migration.up }.to raise_error(CassandraMigrations::Errors::MigrationDefinitionError, /:limit option should be 4 or 8 for float./)
      end
    end

    context 'with a float column declaration without precision' do
      before do
        @migration = FloatDefaultColumnDeclarationMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, a_float float, PRIMARY KEY(id))"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'with a float column declaration with precision 4' do
      before do
        @migration = Float4ColumnDeclarationMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, a_float_4 float, PRIMARY KEY(id))"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'with a float column declaration with precision 8' do
      before do
        @migration = Float8ColumnDeclarationMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, a_float_8 double, PRIMARY KEY(id))"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'with a decimal column declaration' do
      before do
        @migration = DecimalColumnDeclarationMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, a_decimal decimal, PRIMARY KEY(id))"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'with clustering order' do
      before do
        @migration = WithClusteringOrderMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, a_decimal decimal, PRIMARY KEY(id)) WITH CLUSTERING ORDER BY (a_decimal DESC)"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'with compact storage' do
      before do
        @migration = WithCompactStorageMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, a_decimal decimal, PRIMARY KEY(id)) WITH COMPACT STORAGE"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'with other property' do
      before do
        @migration = WithPropertyMigration.new
      end

      it 'should produce a valid CQL create statement' do
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, a_decimal decimal, PRIMARY KEY(id)) WITH gc_grace_seconds = 43200"
        expect(@migration.cql).to eq(expected_cql)
      end
    end

    context 'using a different keyspace' do
      before do
        @migration = WithAlternateKeyspaceMigration.new
        allow(Rails).to receive(:root).and_return Pathname.new("spec/fixtures")
        allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("development")
      end

      it 'should produce a valid CQL create statement' do
        allow(CassandraMigrations::Cassandra).to receive(:use)
        @migration.up
        expected_cql = "CREATE TABLE collection_lists (id uuid, a_decimal decimal, PRIMARY KEY(id)) WITH COMPACT STORAGE"
        expect(@migration.cql).to eq(expected_cql)
      end

      it 'should set and reset the keyspace' do

        expected_cql = "CREATE TABLE collection_lists (id uuid, a_decimal decimal, PRIMARY KEY(id)) WITH COMPACT STORAGE"
        original_keyspace = CassandraMigrations::Config.keyspace
        allow(CassandraMigrations::Cassandra).to receive(:use).with('alternative')
        allow(@migration).to receive(:execute).with(expected_cql)
        allow(CassandraMigrations::Cassandra).to receive(:use).with(original_keyspace)
        @migration.up
      end
    end

    context 'counter columns' do
      before do
        allow(Rails).to receive(:root).and_return Pathname.new("spec/fixtures")
        allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("development")
      end

      it 'should produce a valid CQL create statement if there are no non-key fields except for the counter' do
        migration = WithCounterColumnMigration.new
        migration.up
        expected_cql = "CREATE TABLE with_counter (id uuid, counter_value counter, PRIMARY KEY(id))"
        expect(migration.cql).to eq(expected_cql)
      end
      it 'should produce a valid CQL create statement if there are no non-key fields except for the counter with multiple counters' do
        migration = WithMultipleCounterColumnMigration.new
        migration.up
        expected_cql = "CREATE TABLE with_counter (id uuid, counter_value counter, counter_value2 counter, PRIMARY KEY(id))"
        expect(migration.cql).to eq(expected_cql)
      end

      it 'should raise an exception when there are non-key fields other than the counter' do
        migration = WrongWithCounterColumnMigration.new
        expect { migration.up }.to raise_error(CassandraMigrations::Errors::MigrationDefinitionError, /Non key fields not allowed in tables with counter/)
      end
    end
  end
end
