# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Cassandra do
  
  before do
    Rails.stub(:root).and_return Pathname.new("spec/fixtures")
    Rails.stub(:env).and_return ActiveSupport::StringInquirer.new("development")
  end
  
  after do
    CassandraMigrations::Cassandra.shutdown! if CassandraMigrations::Cassandra.client
  end
  
  describe '.execute' do
    it 'should connect to cassandra using host and port configured' do
      cql_client_mock = Cql::Client.new
      Cql::Client.should_receive(:new).with(:host => '127.0.0.1', :port => 9042).and_return(cql_client_mock)
      cql_client_mock.should_receive(:connect)
      cql_client_mock.should_receive(:execute).with('anything').and_return(nil)
    
      CassandraMigrations::Cassandra.execute('anything').should be_nil
    end
    
    it 'raise exception if there is something wrong with the connection' do
      cql_client_mock = Cql::Client.new
      Cql::Client.should_receive(:new).and_return(cql_client_mock)
      cql_client_mock.should_receive(:connect).and_raise(Cql::Io::ConnectionError)

      expect {    
        CassandraMigrations::Cassandra.execute('anything')
      }.to raise_exception CassandraMigrations::Errors::ConnectionError
    end
    
    it 'should return a QueryResult if the query returns something' do
      CassandraMigrations::Cassandra.client = Cql::Client.new
      
      result_mock = mock('result_mock')
      CassandraMigrations::Cassandra.client.should_receive(:execute).with('anything').and_return(result_mock)
      
      result = CassandraMigrations::Cassandra.execute('anything')
      result.should_not be_nil
      result.should be_a(CassandraMigrations::Cassandra::QueryResult)
    end
  end
  
  describe '.use' do
    it 'should connect to cassandra using host and port configured' do
      cql_client_mock = Cql::Client.new
      Cql::Client.should_receive(:new).with(:host => '127.0.0.1', :port => 9042).and_return(cql_client_mock)
      cql_client_mock.should_receive(:connect)
      cql_client_mock.should_receive(:use).with('anything').and_return(nil)
    
      CassandraMigrations::Cassandra.use('anything').should be_nil
    end
    
    it "should raise exception if configured keyspace does not exist" do
      expect {
        CassandraMigrations::Cassandra.use('anything')
      }.to raise_exception CassandraMigrations::Errors::UnexistingKeyspaceError
    end
  end
  
  # describe ".start!" do
    # it "should use host and port configurations to create cassandra client" do
      # cql_client_mock = Cql::Client.new
      # cql_client_mock.should_receive(:connect)
      # cql_client_mock.stub(:use)
      # Cql::Client.should_receive(:new).with(:host => '127.0.0.1', :port => 9042).and_return(cql_client_mock)
#       
      # CassandraMigrations::Cassandra.start!
    # end
#     
    # it "should raise exception if not able to connect to cassandra host" do
      # cql_client_mock = Cql::Client.new
      # cql_client_mock.stub(:connect).and_raise Cql::Io::ConnectionError
      # Cql::Client.stub(:new).and_return cql_client_mock
#       
      # expect do
        # CassandraMigrations::Cassandra.start!
      # end.to raise_exception CassandraMigrations::Cassandra::Errors::ConnectionError
    # end
#     
    # it "should automatically use configured keyspace" do
      # CassandraMigrations::Cassandra.should_receive(:use).with('cassandra_migrations_development')
      # CassandraMigrations::Cassandra.start!
    # end
  # end
#   
#   
#   
  # describe "query interface" do
    # it "should respond to query methods" do
      # CassandraMigrations::Cassandra.should respond_to :select
      # CassandraMigrations::Cassandra.should respond_to :write
      # CassandraMigrations::Cassandra.should respond_to :delete
      # CassandraMigrations::Cassandra.should respond_to :truncate 
    # end
  # end
  
end
