require "spec_helper"

describe MysqlOnlineMigrations do
  let(:migration) { migration = ActiveRecord::Migration.new }

  context ".prepended" do
    it "sets ActiveRecord::Base.mysql_online_migrations to true" do
      expect(ActiveRecord::Base.mysql_online_migrations).to be_truthy
    end
  end

  context "#connection" do
    shared_examples_for "Mysql2AdapterWithoutLock created" do |verbose|
      it "memoizes an instance of Mysql2AdapterWithoutLock" do
        MysqlOnlineMigrations.verbose = verbose

        expect(ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock).to receive(:new)
          .with(an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2Adapter), verbose).once.and_call_original
        3.times { migration.connection }
      end
    end

    context 'when migrating' do
      it "returns an instance of Mysql2AdapterWithoutLock" do
        expect(migration.connection).to be_an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock)
      end

      it_behaves_like "Mysql2AdapterWithoutLock created"
    end

    context 'when migrating with verbose output' do
      it_behaves_like "Mysql2AdapterWithoutLock created", true
    end

    context 'when rolling back' do
      before do
        migration.instance_variable_set(:@connection, ActiveRecord::Migration::CommandRecorder.new(ActiveRecord::Base.connection))
      end

      it "returns an instance of ActiveRecord::Migration::CommandRecorder" do
        recorder_connection = migration.connection
        expect(recorder_connection).to be_an_instance_of(ActiveRecord::Migration::CommandRecorder)
        expect(recorder_connection.instance_variable_get(:@delegate)).to be_an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock)
      end

      it_behaves_like "Mysql2AdapterWithoutLock created"
    end
  end

  context "#with_lock" do
    it "switches mysql_online_migrations flag to false and then back to original value after block execution" do
      expect(ActiveRecord::Base.mysql_online_migrations).to be_truthy
      migration.with_lock do
        expect(ActiveRecord::Base.mysql_online_migrations).to be_falsy
      end
      expect(ActiveRecord::Base.mysql_online_migrations).to be_truthy
    end
  end
end
