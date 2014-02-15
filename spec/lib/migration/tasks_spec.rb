require "spec_helper"

describe "Migration Tasks" do
  after(:each) do
    @adapter_without_lock.drop_table :test_rake rescue nil
    clear_version
  end

  context 'db:migrate' do
    it "creates the expected column" do
      @adapter_without_lock.tables.should_not include("test_rake")
      ActiveRecord::Migrator.migrate("spec/fixtures/db/migrate")
      @adapter_without_lock.tables.should include("test_rake")
    end
  end

  context 'when rolling back' do
    before(:each) do
      @adapter_without_lock.create_table :test_rake
      @adapter_without_lock.tables.should include("test_rake")
      insert_version(20140108194650)
    end

    context 'db:rollback' do
      it "drops the expected table" do
        ActiveRecord::Migrator.rollback("spec/fixtures/db/migrate", 1)
        @adapter_without_lock.tables.should_not include("test_rake")
      end
    end

    context 'db:migrate:down' do
      it "drops the expected table" do
        ActiveRecord::Migrator.run(:down, "spec/fixtures/db/migrate", 20140108194650)
        @adapter_without_lock.tables.should_not include("test_rake")
      end
    end
  end
end