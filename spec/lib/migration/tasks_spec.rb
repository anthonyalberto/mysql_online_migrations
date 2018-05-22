require "spec_helper"

describe "Migration Tasks" do
  after(:each) do
    @adapter_without_lock.drop_table :test_rake rescue nil
    clear_version
  end

  context 'db:migrate' do
    it "creates the expected table" do
      expect(@adapter_without_lock.tables).not_to include("test_rake")
      ActiveRecord::Migrator.migrate("spec/fixtures/db/migrate")
      expect(@adapter_without_lock.tables).to include("test_rake")
    end
  end

  context 'when rolling back' do
    before(:each) do
      @adapter_without_lock.create_table :test_rake
      expect(@adapter_without_lock.tables).to include("test_rake")
      insert_version(20140108194650)
    end

    context 'db:rollback' do
      it "drops the expected table" do
        ActiveRecord::Migrator.rollback("spec/fixtures/db/migrate", 1)
        expect(@adapter_without_lock.tables).not_to include("test_rake")
      end
    end

    context 'db:migrate:down' do
      it "drops the expected table" do
        ActiveRecord::Migrator.run(:down, "spec/fixtures/db/migrate", 20140108194650)
        expect(@adapter_without_lock.tables).not_to include("test_rake")
      end
    end
  end
end
