require "spec_helper"

describe MysqlOnlineMigrations::Columns do
  let(:comma_before_lock_none) { true }
  let(:queries_with_lock) { {} }

  context "#add_column" do
    let(:queries) do
      {
        [:testing, :foo2, :string, {}] =>
          "ALTER TABLE `testing` ADD `foo2` varchar(255)",
        [:testing, :foo2, :string, { limit: 20, null: false, default: 'def' }] =>
          "ALTER TABLE `testing` ADD `foo2` varchar(20) DEFAULT 'def' NOT NULL",
        [:testing, :foo2, :decimal, { precision:3, scale: 2 }] =>
          "ALTER TABLE `testing` ADD `foo2` decimal(3,2)",
      }
    end

    let(:method_name) { :add_column }

    it_behaves_like "a method that adds LOCK=NONE when needed"
    it_behaves_like "a request with LOCK=NONE that doesn't crash in MySQL"
  end

  context "#add_timestamps" do
    let(:queries) do
      {
        [:testing2, {}] =>
          [
            "ALTER TABLE `testing2` ADD `created_at` datetime",
            "ALTER TABLE `testing2` ADD `updated_at` datetime",
          ]
      }
    end

    let(:method_name) { :add_timestamps }

    it_behaves_like "a method that adds LOCK=NONE when needed"
    it_behaves_like "a request with LOCK=NONE that doesn't crash in MySQL"
  end

  context "#remove_column" do
    let(:queries) do
      {
        [:testing, :foo, {}] =>
          "ALTER TABLE `testing` DROP `foo`",
        [:testing, [:foo, :bar], {}] =>
          [
            "ALTER TABLE `testing` DROP `foo`",
            "ALTER TABLE `testing` DROP `bar`"
          ],
        [:testing, :foo, :bar, {}] =>
          [
            "ALTER TABLE `testing` DROP `foo`",
            "ALTER TABLE `testing` DROP `bar`"
          ]
      }
    end

    let(:method_name) { :remove_column }

    it_behaves_like "a method that adds LOCK=NONE when needed"
    it_behaves_like "a request with LOCK=NONE that doesn't crash in MySQL"
  end

  context "#remove_timestamps" do
    let(:queries) do
      {
        [:testing, {}] =>
          [
            "ALTER TABLE `testing` DROP `created_at`",
            "ALTER TABLE `testing` DROP `updated_at`",
          ]
      }
    end

    let(:method_name) { :remove_timestamps }

    it_behaves_like "a method that adds LOCK=NONE when needed"
    it_behaves_like "a request with LOCK=NONE that doesn't crash in MySQL"
  end

  context "#change_column" do
    let(:queries) do
      # Unsupported with lock=none : change column type, change limit, set NOT NULL.
      {
        [:testing, :foo, :string, { default: 'def', limit: 100 }] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` varchar(100) DEFAULT 'def'",
        [:testing, :foo, :string, { null: true, limit: 100 }] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` varchar(100) DEFAULT NULL",
      }
    end

    let(:queries_with_lock) do
      {
        [:testing, :foo, :string, { limit: 200 }] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` varchar(200) DEFAULT NULL",
        [:testing, :foo, :string, { default: 'def' }] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` varchar(255) DEFAULT 'def'",
        [:testing, :foo, :string, { null: false }] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` varchar(255) NOT NULL",
        [:testing, :foo, :string, { null: false, default: 'def', limit: 200 }] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` varchar(200) DEFAULT 'def' NOT NULL",
        [:testing, :foo, :string, { null: true }] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` varchar(255) DEFAULT NULL",
        [:testing, :foo, :integer, { null: true, limit: 6 }] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` bigint DEFAULT NULL",
        [:testing, :foo, :integer, { null: true, limit: 1 }] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` tinyint DEFAULT NULL"
      }
    end

    let(:method_name) { :change_column }

    it_behaves_like "a method that adds LOCK=NONE when needed"
    it_behaves_like "a request with LOCK=NONE that doesn't crash in MySQL"
    it_behaves_like "queries_with_lock that executes properly"
  end

  context "#change_column_default" do
    let(:queries) do
      {
        [:testing, :foo, 'def', {}] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` varchar(100) DEFAULT 'def'",
        [:testing, :foo, nil, {}] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo` varchar(100) DEFAULT NULL"
      }
    end

    let(:method_name) { :change_column_default }

    it_behaves_like "a method that adds LOCK=NONE when needed"
    it_behaves_like "a request with LOCK=NONE that doesn't crash in MySQL"
    it_behaves_like "queries_with_lock that executes properly"
  end

  context "#change_column_null" do
    let(:queries) do
      #change_column_null doesn't set DEFAULT in sql. It just issues an update statement before setting the NULL value if setting NULL to false
      {
        [:testing, :bam, true, nil, {}] =>
          "ALTER TABLE `testing` CHANGE `bam` `bam` varchar(100) DEFAULT 'test'",
        [:testing, :bam, true, 'def', {}] =>
          "ALTER TABLE `testing` CHANGE `bam` `bam` varchar(100) DEFAULT 'test'"
      }
    end

    let(:queries_with_lock) do
      {
        [:testing, :bam, false, nil, {}] =>
          "ALTER TABLE `testing` CHANGE `bam` `bam` varchar(100) DEFAULT 'test' NOT NULL",
        [:testing, :bam, false, 'def', {}] =>
          [
            "UPDATE `testing` SET `bam`='def' WHERE `bam` IS NULL",
            "ALTER TABLE `testing` CHANGE `bam` `bam` varchar(100) DEFAULT 'test' NOT NULL"
          ]
      }
    end

    let(:method_name) { :change_column_null }

    it_behaves_like "a method that adds LOCK=NONE when needed"
    it_behaves_like "a request with LOCK=NONE that doesn't crash in MySQL"
    it_behaves_like "queries_with_lock that executes properly"
  end

  context "#rename_column" do
    let(:queries) do
      {
        [:testing, :foo, :foo2, {}] =>
          "ALTER TABLE `testing` CHANGE `foo` `foo2` varchar(100) DEFAULT NULL"
      }
    end

    let(:method_name) { :rename_column }

    it_behaves_like "a method that adds LOCK=NONE when needed"
    it_behaves_like "a request with LOCK=NONE that doesn't crash in MySQL"
  end
end