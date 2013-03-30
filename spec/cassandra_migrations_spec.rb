# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations do
  it "should define modules" do
    defined?(CassandraMigrations).should be_true
    defined?(CassandraMigrations::Railtie).should be_true
    defined?(CassandraMigrations::Cassandra).should be_true
    defined?(CassandraMigrations::Cassandra::Query).should be_true
    defined?(CassandraMigrations::Cassandra::Errors).should be_true
    defined?(CassandraMigrations::Cassandra::Migrator).should be_true
  end
end