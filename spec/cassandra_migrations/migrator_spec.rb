# encoding : utf-8
require 'spec_helper'
require_relative '../fixtures/db/cassandra_migrate/20160523185719_create_test_table'
require_relative '../fixtures/db/cassandra_migrate/12345_release_12345'

describe CassandraMigrations::Migrator do

  before do
    allow(Rails).to receive(:root).and_return Pathname.new("#{Dir.pwd}/spec/fixtures")
    allow(described_class).to receive(:read_current_version).and_return(0)
  end

  it "finds and runs all valid migrations" do
    allow(CassandraMigrations::Cassandra).to receive(:write!).at_least(:twice).with(any_args).and_return(nil)

    expect_any_instance_of(CreateTestTable).to receive(:migrate).with(:up)
    expect_any_instance_of(Release12345).to receive(:migrate).with(:up)

    described_class.up_to_latest!
  end

  it "only runs migrations with version numbers greater than those of the previously run migrations" do
    allow(described_class).to receive(:read_current_version).and_return(23456)
    allow(CassandraMigrations::Cassandra).to receive(:write!).once.with(any_args).and_return(nil)

    expect_any_instance_of(CreateTestTable).to receive(:migrate).with(:up)
    expect_any_instance_of(Release12345).not_to receive(:migrate).with(:up)

    described_class.up_to_latest!
  end

  it "requires the migrations to begin with a version number" do
    allow(described_class).to receive(:get_all_migration_names).and_return(["#{Dir.pwd}/spec/fixtures/db/cassandra_migrate/no_numbers_here"])

    expect { described_class.up_to_latest! }.to raise_exception(CassandraMigrations::Errors::MigrationNamingError, "Migration file names must start with a numeric version prefix.".red)
  end

  it "requires the class name of the migration to match the file name" do
    allow(described_class).to receive(:get_all_migration_names).and_return(["#{Dir.pwd}/spec/fixtures/db/cassandra_migrate/invalid/12345_non_matching_filename.rb"])

    expect { described_class.up_to_latest! }.to raise_exception(CassandraMigrations::Errors::MigrationNamingError, "Migration file names must match the class name in the migration—could not find class NonMatchingFilename.".red)
  end
end
