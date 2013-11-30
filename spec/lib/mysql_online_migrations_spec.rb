require "spec_helper"

describe MysqlOnlineMigrations do
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