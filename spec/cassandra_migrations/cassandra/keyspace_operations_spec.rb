# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Cassandra::KeyspaceOperations do

  describe "#create_keyspace_statement" do
    let(:config) { CassandraMigrations::Config.configurations[env] }
    let(:extended_object) { Object.new.extend(described_class) }

    before do
      allow(Rails).to receive(:root).and_return Pathname.new("spec/fixtures")
    end

    context "for a SimpleStrategy keyspace" do
      let(:env) { "test" }

      it "includes the correct CQL statement with replication factor" do
        expected_statement =  "CREATE KEYSPACE my_keyspace_test\nWITH replication = {\n  'class': 'SimpleStrategy',\n  'replication_factor': 1\n}\n"

        expect(extended_object.create_keyspace_statement(config)).to eq(expected_statement)
      end
    end

    context "for a NetworkTopologyStrategy keyspace" do
      let(:env) { "test_with_network_topology_strategy" }

      it "includes the correct CQL statement with " do
        expected_statement =  "CREATE KEYSPACE my_keyspace_test_network_topology\nWITH replication = {\n  'class': 'NetworkTopologyStrategy',\n  'testdc': 1, 'dc2': 2\n}\n"

        expect(extended_object.create_keyspace_statement(config)).to eq(expected_statement)
      end
    end
  end
end

