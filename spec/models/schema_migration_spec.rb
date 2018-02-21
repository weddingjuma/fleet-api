require 'rails_helper'

RSpec.describe SchemaMigration, type: :model do

  before(:all) do
    @schema_migration = SchemaMigration.create(migration: '201820021420_test_migration',
                                         date: DateTime.now.to_s)
  end

  subject { @schema_migration }

  context 'Object' do
    it { is_expected.to be_valid }
    it { expect(@schema_migration.migration).to eq '201820021420_test_migration' }
    it { expect(@schema_migration.migration).to be_a String }  end

  context 'Views' do
    it 'returns all schema migration' do
      expect(SchemaMigration.all.to_a.size).to eq(1)
    end

    it 'returns all schema_migrations by migration' do
      expect(SchemaMigration.by_migration(key: '201820021420_test_migration').to_a.size).to eq(1)
    end

    it 'returns schema_migration by migration' do
      expect(SchemaMigration.find_by('201820021420_test_migration').id).to eq(@schema_migration.id)
    end

  end

end
