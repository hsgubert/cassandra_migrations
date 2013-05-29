# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Cassandra do
  
  it "should initialize without client or config" do
    CassandraMigrations::Cassandra.client.should be_nil
    CassandraMigrations::Cassandra.config.should be_nil
  end
  
  before do
    Rails.stub(:root).and_return Pathname.new("spec/fixtures")
    Rails.stub(:env).and_return ActiveSupport::StringInquirer.new("development")
  end
  
  after do
    CassandraMigrations::Cassandra.shutdown! if CassandraMigrations::Cassandra.client
  end
  
  describe ".start!" do
    it "should raise exception if config/cassandra.yaml is not found" do
      Rails.stub(:root).and_return Pathname.new("wrong_path")
      
      expect do
        CassandraMigrations::Cassandra.start!
      end.to raise_exception CassandraMigrations::Cassandra::Errors::MissingConfigurationError
    end
    
    it "should load config/cassandra.yaml environment specific part in self.config" do
      begin
        CassandraMigrations::Cassandra.start!
      rescue
      end
      
      CassandraMigrations::Cassandra.config.should == {
        'host' => "127.0.0.1",
        'port' => 9042,
        'keyspace' => "cassandra_migrations_development",
        'replication' => {
          'class' => "SimpleStrategy",
          'replication_factor' => 1
        }
      }
    end
    
    it "should use host and port configurations to create cassandra client" do
      cql_client_mock = Cql::Client.new
      cql_client_mock.should_receive(:connect)
      cql_client_mock.stub(:use)
      Cql::Client.should_receive(:new).with(:host => '127.0.0.1', :port => 9042).and_return(cql_client_mock)
      
      CassandraMigrations::Cassandra.start!
    end
    
    it "should raise exception if not able to connect to cassandra host" do
      cql_client_mock = Cql::Client.new
      cql_client_mock.stub(:connect).and_raise Cql::Io::ConnectionError
      Cql::Client.stub(:new).and_return cql_client_mock
      
      expect do
        CassandraMigrations::Cassandra.start!
      end.to raise_exception CassandraMigrations::Cassandra::Errors::ConnectionError
    end
    
    it "should automatically use configured keyspace" do
      CassandraMigrations::Cassandra.should_receive(:use).with('cassandra_migrations_development')
      CassandraMigrations::Cassandra.start!
    end
  end
  
  describe '.use' do
    it "should raise exception if configured keyspace does not exist" do
      expect do
        CassandraMigrations::Cassandra.start!
      end.to raise_exception CassandraMigrations::Cassandra::Errors::UnexistingKeyspaceError
    end
  end
  
  describe "query interface" do
    it "should respond to query methods" do
      CassandraMigrations::Cassandra.should respond_to :select
      CassandraMigrations::Cassandra.should respond_to :write
      CassandraMigrations::Cassandra.should respond_to :delete
      CassandraMigrations::Cassandra.should respond_to :truncate 
    end
  end
  
end
