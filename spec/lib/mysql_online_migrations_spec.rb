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

  context "migration behaviour" do
    let(:comma_before_lock_none) { false }
    let(:method_name) { :add_index }
    let(:queries) do
      {
        [:testing, :foo, {}] =>
          "CREATE INDEX `index_testing_on_foo` ON `testing` (`foo`)",
        [:testing, :foo, { length: 10 }] =>
          "CREATE INDEX `index_testing_on_foo` ON `testing` (`foo`(10))",
        [:testing, [:foo, :bar, :baz], {}] =>
          "CREATE INDEX `index_testing_on_foo_and_bar_and_baz` ON `testing` (`foo`, `bar`, `baz`)",
        [:testing, [:foo, :bar, :baz], { unique: true }] =>
          "CREATE UNIQUE INDEX `index_testing_on_foo_and_bar_and_baz` ON `testing` (`foo`, `bar`, `baz`)",
        [:testing, [:foo, :bar, :baz], { unique: true, name: "best_index_of_the_world" }] =>
          "CREATE UNIQUE INDEX `best_index_of_the_world` ON `testing` (`foo`, `bar`, `baz`)",
      }
    end

    it "executes each command with LOCK=NONE at the end" do
      stub_adapter_without_lock
      stub_original_execute

      queries.each do |args, sql|
        migration = ActiveRecord::Migration.new
        migration.instance_variable_set(:@test_method_name, method_name)
        migration.instance_variable_set(:@test_args, args)
        migration.define_singleton_method(:change) do
          public_send(@test_method_name, *@test_args)
        end
        should_receive(:execute).with(add_lock_none(sql, comma_before_lock_none))
        migration.migrate(:up)
      end
    end
  end
end