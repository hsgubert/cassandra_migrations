# encoding : utf-8

class CassandraMigrations::Railtie < ::Rails::Railtie
  
  initializer "cassandra_migrations.initializer" do
    require File.expand_path('railtie/initializer', File.dirname(__FILE__))
  end

  rake_tasks do
    Dir[File.expand_path("railtie/**/*.rake", File.dirname(__FILE__))].each do |file| 
      # 'load' is used because 'require' is only for .rb files
      load file
    end
  end
  
end
