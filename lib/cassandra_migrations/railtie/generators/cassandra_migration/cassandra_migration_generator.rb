class CassandraMigrationGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', File.dirname(__FILE__))
  
  argument :migration_name, :type => :string
  
  # Interpolates template and creates migration in the application
  #
  # Any public method in the generator is run automatically when 
  # the generator is run. To understand fully see 
  # http://asciicasts.com/episodes/218-making-generators-in-rails-3
  
  def generate_migration
    file_name = "#{Time.current.utc.strftime('%Y%m%d%H%M%S')}_#{migration_name.underscore}"
    @migration_class_name = migration_name.camelize
    
    template "empty_migration.rb.erb", "db/cassandra_migrate/#{file_name}.rb"  
  end
end
