require "spec_helper"

describe MysqlOnlineMigrations do
  let(:migration) { migration = ActiveRecord::Migration.new }

  context ".prepended" do
    it "sets ActiveRecord::Base.mysql_online_migrations to true" do
      ActiveRecord::Base.mysql_online_migrations.should be_true
    end
  end

  context "#connection" do
    shared_examples_for "Mysql2AdapterWithoutLock created" do
      it "memoizes an instance of Mysql2AdapterWithoutLock" do
        ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock.should_receive(:new)
          .with(an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2Adapter)).once.and_call_original
        3.times { migration.connection }
      end
    end

    context 'when migrating' do
      it "returns an instance of Mysql2AdapterWithoutLock" do
        migration.connection.should be_an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock)
      end

      it_behaves_like "Mysql2AdapterWithoutLock created"
    end

    context 'when rolling back' do
      before do
        migration.instance_variable_set(:@connection, ActiveRecord::Migration::CommandRecorder.new(ActiveRecord::Base.connection))
      end

      it "returns an instance of ActiveRecord::Migration::CommandRecorder" do
        recorder_connection = migration.connection
        recorder_connection.should be_an_instance_of(ActiveRecord::Migration::CommandRecorder)
        recorder_connection.instance_variable_get(:@delegate).should be_an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock)
      end

      it_behaves_like "Mysql2AdapterWithoutLock created"
    end
  end

  context "#with_lock" do
    it "switches mysql_online_migrations flag to false and then back to original value after block execution" do
      ActiveRecord::Base.mysql_online_migrations.should be_true
      migration.with_lock do
        ActiveRecord::Base.mysql_online_migrations.should be_false
      end
      ActiveRecord::Base.mysql_online_migrations.should be_true
    end
  end

  context "#without_lock" do
    it "switches mysql_online_migrations flag to true and then back to original value after block execution" do
      ActiveRecord::Base.mysql_online_migrations = false
      ActiveRecord::Base.mysql_online_migrations.should be_false
      migration.without_lock do
        ActiveRecord::Base.mysql_online_migrations.should be_true
      end
      ActiveRecord::Base.mysql_online_migrations.should be_false
    end
  end
end
