# encoding: utf-8

require 'cassandra_migrations/migration/table_operations'
require 'cassandra_migrations/migration/column_operations'

module CassandraMigrations
  
  # Base class for all cassandra migration
  class Migration
    
    include TableOperations
    include ColumnOperations
    
    # Makes +execute+ method directly available to migrations
    delegate :execute, :to => Cassandra
    delegate :using_keyspace, :to => Cassandra
    
    # Makes +up+ work if the method in the migration is defined with self.up
    def up
      return unless self.class.respond_to?(:up)
      self.class.instance_to_delegate = self
      self.class.up
    end
    
    # Makes +down+ work if the method in the migration is defined with self.down
    def down
      return unless self.class.respond_to?(:down)
      self.class.instance_to_delegate = self
      self.class.down
    end
    
    # Class variable that holds an instance of Migration when the methods +up+ or
    # +down+ are called on the class. The class then delegates missing method
    # calls to this instance.
    cattr_accessor :instance_to_delegate, :instance_accessor => false
    
    # Delegate missing method calls to an instance. That's what enables the
    # writing of migrations using both +def up+ and +def self.up+ sintax.
    def self.method_missing(name, *args, &block)
      if instance_to_delegate
        instance_to_delegate.send(name, *args, &block)
      else
        super
      end
    end
    
    # Execute this migration in the named direction.
    #
    # The advantage of using this instead of directly calling up or down is that
    # this method gives informative output and benchmarks the time taken.
    def migrate(direction)
      return unless respond_to?(direction)

      case direction
      when :up   then announce_migration "migrating"
      when :down then announce_migration "reverting"
      end

      time = Benchmark.measure { send(direction) }

      case direction
      when :up   then announce_migration "migrated (%.4fs)" % time.real; puts
      when :down then announce_migration "reverted (%.4fs)" % time.real; puts
      end
    end  
    
  private
  
    # Generates output labeled with name of migration and a line that goes up 
    # to 75 characters long in the terminal
    def announce_migration(message)
      text = "#{name}: #{message}"
      length = [0, 75 - text.length].max
      puts "== %s %s" % [text, "=" * length]
    end
    
    def announce_operation(message)
      puts "  " + message
    end
    
    def announce_suboperation(message)
      puts "  -> " + message
    end
    
    # Gets the name of the migration
    def name
      self.class.name
    end
  end
end
