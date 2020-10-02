require "spec_helper"

describe "Migration Tasks" do
  after(:each) do
    @adapter_without_lock.drop_table :test_rake rescue nil
    clear_version
  end

  def execute_migration_by(method_name, direction: nil, target_version: nil, steps: nil)
    if ActiveRecord::VERSION::MAJOR >= 6
      ActiveRecord::MigrationContext.new("spec/fixtures/db/migrate",
                                         ActiveRecord::Base.connection.schema_migration)
                                    .__send__(*[method_name, direction, target_version, steps].compact)
    elsif ActiveRecord::VERSION::MAJOR >= 5 && ActiveRecord::VERSION::MINOR >= 2
      ActiveRecord::MigrationContext.new("spec/fixtures/db/migrate")
                                    .__send__(*[method_name, direction, target_version, steps].compact)
    else
      ActiveRecord::Migrator.__send__(*[method_name, direction, "spec/fixtures/db/migrate", target_version, steps].compact)
    end
  end

  context 'db:migrate' do
    it "creates the expected column" do
      expect(@adapter_without_lock.tables).not_to include("test_rake")
      execute_migration_by(:migrate)
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
        execute_migration_by(:rollback, steps: 1)
        expect(@adapter_without_lock.tables).not_to include("test_rake")
      end
    end

    context 'db:migrate:down' do
      it "drops the expected table" do
        execute_migration_by(:run, direction: :down, target_version: 20140108194650)
        expect(@adapter_without_lock.tables).not_to include("test_rake")
      end
    end
  end
end