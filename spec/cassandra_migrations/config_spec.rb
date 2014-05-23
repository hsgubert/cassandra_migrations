# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Config do
  
  before do
    CassandraMigrations::Config.configurations = nil
  end
  
  it 'should fetch values in config for the right environment' do
    Rails.stub(:root).and_return Pathname.new("spec/fixtures")
    Rails.stub(:env).and_return ActiveSupport::StringInquirer.new("development")
    
    CassandraMigrations::Config.keyspace.should == 'cassandra_migrations_development'
    CassandraMigrations::Config.replication.should == {'class' => "SimpleStrategy", 'replication_factor' => 1 }
  end
  
  it 'should raise exception if there are no configs for environment' do
    Rails.stub(:root).and_return Pathname.new("spec/fixtures")
    Rails.stub(:env).and_return ActiveSupport::StringInquirer.new("fake_environment")
    
    expect {
      CassandraMigrations::Config.keyspace
    }.to raise_exception CassandraMigrations::Errors::MissingConfigurationError
  end
  
  it 'should raise exception if there are no config file' do
    Rails.stub(:root).and_return Pathname.new("spec/fake_path")
    Rails.stub(:env).and_return ActiveSupport::StringInquirer.new("development")
    
    expect {
      CassandraMigrations::Config.keyspace
    }.to raise_exception CassandraMigrations::Errors::MissingConfigurationError
  end
  
  it 'should allow ERB in the config file' do
    Rails.stub(:root).and_return Pathname.new("spec/fixtures/with_erb")
    Rails.stub(:env).and_return ActiveSupport::StringInquirer.new("test")
    
    CassandraMigrations::Config.keyspace.should == 'cassandra_migrations_test'
    
    CassandraMigrations::Config.configurations = nil
    ENV.stub(:[]).with("CI").and_return("true")
    
    CassandraMigrations::Config.keyspace.should == 'cassandra_migrations_ci'
  end

  it 'allows access to configurations for other environments than the current Rails.env' do
    Rails.stub(:root).and_return Pathname.new("spec/fixtures")
    Rails.stub(:env).and_return ActiveSupport::StringInquirer.new("development")
    CassandraMigrations::Config.configurations['production'].keyspace.should == 'cassandra_migrations_production'
  end
end
  