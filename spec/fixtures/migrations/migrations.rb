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

