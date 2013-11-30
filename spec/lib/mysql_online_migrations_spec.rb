require "spec_helper"

describe MysqlOnlineMigrations do
  let(:migration) { migration = ActiveRecord::Migration.new }

  context ".prepended" do
    it "sets ActiveRecord::Base.mysql_online_migrations to true" do
      ActiveRecord::Base.mysql_online_migrations.should be_true
    end
  end

  context "#connection" do
    it "memoizes an instance of Mysql2AdapterWithoutLock" do
      ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock.should_receive(:new)
        .with(an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2Adapter)).once.and_call_original
      3.times { @connection = migration.connection }
      @connection.should be_an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock)
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
end