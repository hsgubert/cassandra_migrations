# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Config do

  before do
    CassandraMigrations::Config.configurations = nil
  end

  it 'should fetch values in config for the right environment' do
    allow(Rails).to receive(:root).and_return Pathname.new("spec/fixtures")
    allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("development")

    expect(CassandraMigrations::Config.keyspace).to eq('cassandra_migrations_development')
    expect(CassandraMigrations::Config.replication).to eq({'class' => "SimpleStrategy", 'replication_factor' => 1 })
  end

  it 'should raise exception if there are no configs for environment' do
    allow(Rails).to receive(:root).and_return Pathname.new("spec/fixtures")
    allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("fake_environment")

    expect {
      CassandraMigrations::Config.keyspace
    }.to raise_exception CassandraMigrations::Errors::MissingConfigurationError
  end

  it 'should raise exception if there are no config file' do
    allow(Rails).to receive(:root).and_return Pathname.new("spec/fake_path")
    allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("development")

    expect {
      CassandraMigrations::Config.keyspace
    }.to raise_exception CassandraMigrations::Errors::MissingConfigurationError
  end

  it 'should allow ERB in the config file' do
    allow(Rails).to receive(:root).and_return Pathname.new("spec/fixtures/with_erb")
    allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("test")

    expect(CassandraMigrations::Config.keyspace).to eq('cassandra_migrations_test')

    CassandraMigrations::Config.configurations = nil
    allow(ENV).to receive(:[]).with("CI").and_return("true")

    expect(CassandraMigrations::Config.keyspace).to eq('cassandra_migrations_ci')
  end

  it 'allows access to configurations for other environments than the current Rails.env' do
    allow(Rails).to receive(:root).and_return Pathname.new("spec/fixtures")
    allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("development")
    expect(CassandraMigrations::Config.configurations['production'].keyspace).to eq('cassandra_migrations_production')
  end
end
