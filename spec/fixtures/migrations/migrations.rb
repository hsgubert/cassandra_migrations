class WithoutAPrimaryKey < CassandraMigrations::Migration
  def up
    create_table :without_a_primary_key do |t|
      t.uuid :id
    end
  end
end

class CreateKitchenSink < CassandraMigrations::Migration
  def up
    create_table :kitchen_sink do |t|
      t.uuid :id, :primary_key => true
      t.string :a_string
      t.timestamp :a_timestamp
      t.float :a_float
      t.list :a_list_of_strings, :type => :string
    end
  end

  def down
    drop_table :kitchen_sink
  end
end

class CollectionsListMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.list :list_1, :type => :string
    end
  end
end

class BadCollectionsListMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.list :list_1, :type => :chupacabra
    end
  end
end

class CollectionsSetMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.set :set_2, :type => :float
    end
  end
end

class BadCollectionsSetMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.set :set_2, :type => :narwhal
    end
  end
end

class CollectionsMapMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.map :map_1, :key_type => :string, :value_type => :float
    end
  end
end

class CollectionsMapMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.map :map_1, :key_type => :string, :value_type => :float
    end
  end
end

class BadCollectionsMapMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.map :map_1, :key_type => :unicorns, :value_type => :float
    end
  end
end

class MigrationWithSecondaryIndex < CassandraMigrations::Migration
  def up
    create_index :with_indexes, :a_string
  end

  def down
    drop_index :with_indexes, :a_string
  end
end

class MigrationWithANamedSecondaryIndex < CassandraMigrations::Migration
  def up
    create_index :with_indexes, :another_string, :name => 'by_another_string'
  end

  def down
    drop_index 'by_another_string'
  end
end

class CompositePrimaryKey < CassandraMigrations::Migration
  def up
    create_table :composite_primary_key, :primary_keys => [:id, :a_string] do |t|
      t.uuid :id
      t.string :a_string
    end
  end
end

class CompositePartitionKey < CassandraMigrations::Migration
  def up
    create_table :composite_partition_key, :partition_keys => [:id, :a_string], :primary_keys => [:id, :a_string, :a_timestamp] do |t|
      t.uuid :id
      t.string :a_string
      t.timestamp :a_timestamp
    end
  end
end

class BadFloatColumnDeclarationMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.float :a_float, :limit => 3
    end
  end
end

class FloatDefaultColumnDeclarationMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.float :a_float
    end
  end
end

class Float4ColumnDeclarationMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.float :a_float_4, :limit => 4
    end
  end
end

class Float8ColumnDeclarationMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.float :a_float_8, :limit => 8
    end
  end
end

class DecimalColumnDeclarationMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists do |t|
      t.uuid :id, :primary_key => true
      t.decimal :a_decimal
    end
  end
end

class WithClusteringOrderMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists, options: {clustering_order: 'a_decimal DESC'} do |t|
      t.uuid :id, :primary_key => true
      t.decimal :a_decimal
    end
  end
end

class WithCompactStorageMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists, options: {compact_storage: true} do |t|
      t.uuid :id, :primary_key => true
      t.decimal :a_decimal
    end
  end
end

class WithPropertyMigration < CassandraMigrations::Migration
  def up
    create_table :collection_lists, options: {gc_grace_seconds: 43200} do |t|
      t.uuid :id, :primary_key => true
      t.decimal :a_decimal
    end
  end
end

class WithAlternateKeyspaceMigration < CassandraMigrations::Migration
  def up
    using_keyspace('alternative') do
      create_table :collection_lists, options: {compact_storage: true} do |t|
        t.uuid :id, :primary_key => true
        t.decimal :a_decimal
      end
    end
  end
end

class WithCounterColumnMigration < CassandraMigrations::Migration
  def up
    create_table :with_counter do |t|
      t.uuid :id, :primary_key => true
      t.counter :counter_value
    end
  end
end

class WithMultipleCounterColumnMigration < CassandraMigrations::Migration
  def up
    create_table :with_counter do |t|
      t.uuid :id, :primary_key => true
      t.counter :counter_value
      t.counter :counter_value2
    end
  end
end

class WrongWithCounterColumnMigration < CassandraMigrations::Migration
  def up
    create_table :with_counter do |t|
      t.uuid :id, :primary_key => true
      t.string :name
      t.counter :counter_value
    end
  end
end


