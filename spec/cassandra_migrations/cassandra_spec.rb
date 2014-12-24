# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Cassandra do

  before do
    allow(Rails).to receive(:root).and_return Pathname.new("spec/fixtures")
    allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("development")
  end

  after do
    CassandraMigrations::Cassandra.client = nil
    CassandraMigrations::Config.configurations = nil
  end

  describe '.execute' do
    it 'should connect to cassandra using host and port configured' do
      cql_client_mock = double('cql_client')
      allow(Client).to receive(:connect).with(:hosts => ['127.0.0.1'], :port => 9042).and_return(cql_client_mock)
      allow(cql_client_mock).to receive(:execute).with('anything').and_return(nil)

      expect(CassandraMigrations::Cassandra.execute('anything')).to be_nil
    end

    it 'raise exception if there is something wrong with the connection' do
      allow(Client).to receive(:connect).and_raise(Cassandra::Error)

      expect {
        CassandraMigrations::Cassandra.execute('anything')
      }.to raise_exception Exception
    end

    it 'should return a QueryResult if the query returns something' do
      CassandraMigrations::Cassandra.client = double('cql_client')

      result_mock = double('result_mock')
      allow(CassandraMigrations::Cassandra.client).to receive(:execute).with('anything').and_return(result_mock)

      result = CassandraMigrations::Cassandra.execute('anything')
      expect(result).to_not be_nil
      expect(result).to be_a(CassandraMigrations::Cassandra::QueryResult)
    end
  end

  describe '.use' do
    it 'should connect to cassandra using host and port configured' do
      cql_client_mock = double('cql_client')
      allow(Client).to receive(:connect).with(:hosts => ['127.0.0.1'], :port => 9042).and_return(cql_client_mock)
      allow(cql_client_mock).to receive(:use).with('anything').and_return(nil)

      expect(CassandraMigrations::Cassandra.use('anything')).to be_nil
    end

    it "should raise exception if configured keyspace does not exist" do
      expect {
        CassandraMigrations::Cassandra.use('anything')
      }.to raise_exception CassandraMigrations::Errors::UnexistingKeyspaceError
    end
  end

  describe '.using_keyspace' do
    it 'should set use the specified keyspace yield to the block and then reset the keyspace' do
      cql_client_mock = double('cql_client')
      original_keyspace = CassandraMigrations::Config.keyspace
      allow(Client).to receive(:connect).with(:hosts => ['127.0.0.1'], :port => 9042).and_return(cql_client_mock)
      allow(cql_client_mock).to receive(:use).with('anything').and_return(nil)
      allow(cql_client_mock).to receive(:use).with(original_keyspace).and_return(nil)
      expect { |block| CassandraMigrations::Cassandra.using_keyspace('anything', &block) }.to yield_control
    end
  end

  describe ".start!" do
    it "should use configured keyspace" do
      allow(CassandraMigrations::Cassandra).to receive(:use).with('cassandra_migrations_development')
      CassandraMigrations::Cassandra.start!
    end

    it "should log missing configuration file or similar error, but swallow exception" do
      allow(Rails).to receive(:root).and_return Pathname.new("spec/fake_fixture_path")

      Rails.logger = double('logger')
      allow(Rails.logger).to receive(:warn).with('There is no config/cassandra.yml. Skipping connection to Cassandra...')
      CassandraMigrations::Cassandra.start!
    end
  end

  describe "query interface" do
    it "should respond to query helper methods" do
      expect(CassandraMigrations::Cassandra).to respond_to :select
      expect(CassandraMigrations::Cassandra).to respond_to :write!
      expect(CassandraMigrations::Cassandra).to respond_to :update!
      expect(CassandraMigrations::Cassandra).to respond_to :delete!
      expect(CassandraMigrations::Cassandra).to respond_to :truncate!
    end
  end

  describe "keyspace interface" do
    it "should respond to keyspace helper methods" do
      expect(CassandraMigrations::Cassandra).to respond_to :create_keyspace!
      expect(CassandraMigrations::Cassandra).to respond_to :drop_keyspace!
    end
  end
end
