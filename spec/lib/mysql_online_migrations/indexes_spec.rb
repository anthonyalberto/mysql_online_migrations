require "spec_helper"

describe MysqlOnlineMigrations::Indexes do
  let(:comma_before_lock_none) { false }

  context "#add_index" do
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

    let(:method_name) { :add_index }

    it_behaves_like "a method that adds LOCK=NONE when needed"
  end

  context "#remove_index" do
    let(:queries) do
      {
        [:testing, :baz, {}] =>
          "DROP INDEX `index_testing_on_baz` ON `testing`",
        [:testing, [:bar, :baz], {}] =>
          "DROP INDEX `index_testing_on_bar_and_baz` ON `testing`",
        [:testing, { column: [:bar, :baz] }, {}] =>
          "DROP INDEX `index_testing_on_bar_and_baz` ON `testing`",
        [:testing, { name: "best_index_of_the_world2" }, {}] =>
          "DROP INDEX `best_index_of_the_world2` ON `testing`"
      }
    end
    let(:method_name) { :remove_index }

    it_behaves_like "a method that adds LOCK=NONE when needed"
  end

  context "#rename_index" do
    let(:queries) do
      {
        [:testing, "best_index_of_the_world2", "renamed_best_index_of_the_world2", {}] =>
          [
            "DROP INDEX `best_index_of_the_world2` ON `testing`",
            "CREATE INDEX `renamed_best_index_of_the_world2` ON `testing` (`extra`)",
          ],
        [:testing, "best_index_of_the_world3", "renamed_best_index_of_the_world3", {}] =>
          [
            "DROP INDEX `best_index_of_the_world3` ON `testing`",
            "CREATE UNIQUE INDEX `renamed_best_index_of_the_world3` ON `testing` (`baz`, `extra`)",
          ]
      }
    end
    let(:method_name) { :rename_index }

    it_behaves_like "a method that adds LOCK=NONE when needed"
  end
end