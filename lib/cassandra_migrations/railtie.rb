# encoding : utf-8

require 'cassandra_migrations/cassandra'

class CassandraMigrations::Railtie < ::Rails::Railtie
  
  initializer "cassandra_migrations.start" do
    CassandraMigrations::Cassandra.start!
  end

  rake_tasks do
    Dir[File.expand_path("tasks/**/*.rake", File.dirname(__FILE__))].each do |file| 
      load file
    end
  end
  
end
