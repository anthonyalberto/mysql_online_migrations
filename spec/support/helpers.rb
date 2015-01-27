module Helpers
  CATCH_STATEMENT_REGEX = /^(alter|create|drop|update|rename) /i
  DDL_STATEMENT_REGEX  = /^(alter|create (unique )? ?index|drop index) /i
  DEFAULT_VERSION = "20110603153213"

  def build_migration(method_name, args, version=nil, &block)
    version ||= DEFAULT_VERSION
    migration = ActiveRecord::Migration.new
    migration.instance_variable_set(:@test_method_name, method_name)
    migration.instance_variable_set(:@test_args, args)
    migration.instance_variable_set(:@test_block, block)
    migration.define_singleton_method(:change) do
      public_send(@test_method_name, *@test_args, &@test_block)
    end
    migration.version = version
    migration
  end

  def regular_execute(statement)
    @queries_received_by_regular_adapter << statement
  end

  def execute_without_lock(statement)
    @queries_received_by_adapter_without_lock << statement
  end

  def unstub_execute
    allow(@adapter).to receive(:execute).and_call_original
  end

  def stub_adapter_without_lock
    allow(ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock).to receive(:new).and_return(@adapter_without_lock)
  end

  def stub_execute(adapter, original_method, method_to_call)
    original_execute = adapter.method(original_method)

    allow(adapter).to receive(original_method) do |sql|
      if sql =~ CATCH_STATEMENT_REGEX
        send(method_to_call, sql.squeeze(' ').strip)
      else
        original_execute.call(sql)
      end
    end
  end

  def add_lock_none(str, with_comma)
    if str =~ DDL_STATEMENT_REGEX
      "#{str}#{with_comma ? ' ,' : ''} LOCK=NONE"
    else
      str
    end
  end

  def drop_all_tables
    @adapter.tables.each do |table|
      @adapter.drop_table(table) rescue nil
    end
  end

  def rebuild_table
    @table_name = :testing
    drop_all_tables

    @adapter.create_table @table_name do |t|
      t.column :foo, :string, :limit => 100
      t.column :bar, :string, :limit => 100
      t.column :baz, :string, :limit => 100
      t.column :bam, :string, :limit => 100, default: "test", null: false
      t.column :extra, :string, :limit => 100
      t.timestamps
    end

    @table_name = :testing2
    @adapter.create_table @table_name do |t|
    end

    @adapter.add_index :testing, :baz
    @adapter.add_index :testing, [:bar, :baz]
    @adapter.add_index :testing, :extra, name: "best_index_of_the_world2"
    @adapter.add_index :testing, [:baz, :extra], name: "best_index_of_the_world3", unique: true
  end

  def setup
    ActiveRecord::Base.establish_connection(
      adapter: :mysql2,
      database: "mysql_online_migrations",
      username: "travis",
      encoding: "utf8"
    )

    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = Logger::INFO

    @adapter = ActiveRecord::Base.connection
    @adapter_without_lock = ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock.new(@adapter)

    rebuild_table
  end

  def set_ar_setting(value)
    allow(ActiveRecord::Base).to receive(:mysql_online_migrations).and_return(value)
  end

  def set_ignore_setting(value)
    allow(ActiveRecord::Base).to receive(:mysql_online_migrations_ignore).and_return(value)
  end

  def teardown
    @adapter.drop_table :testing rescue nil
    @adapter.drop_table :test_rake rescue nil
    ActiveRecord::Base.primary_key_prefix_type = nil
  end

  def insert_version(version)
    @adapter_without_lock.execute("INSERT into schema_migrations VALUES('#{version}')")
  end

  def clear_version
    @adapter_without_lock.execute("TRUNCATE schema_migrations")
  end
end
