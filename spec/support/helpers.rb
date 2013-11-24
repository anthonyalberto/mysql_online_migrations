module Helpers
  def execute(statement)
  end

  def unstub_execute
    @adapter.unstub(:execute)
  end

  def stub_execute
    original_execute = @adapter.method(:execute)
    @adapter.stub(:execute) do |statement|
      if statement =~ /^(alter|create|drop) /i
        execute(statement.squeeze(' ').strip)
      else
        original_execute.call(statement)
      end
    end
  end

  def add_lock_none(str, with_comma)
    "#{str}#{with_comma ? ' ,' : ''} LOCK=NONE"
  end

  def rebuild_table
    @table_name = :testing
    @adapter.drop_table @table_name rescue nil
    @adapter.create_table @table_name do |t|
      t.column :foo, :string, :limit => 100
      t.column :bar, :string, :limit => 100
      t.column :baz, :string, :limit => 100
      t.column :extra, :string, :limit => 100
      t.timestamps
    end

    @table_name = :testing2
    @adapter.drop_table @table_name rescue nil
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
      reconnect: false,
      database: "mysql_online_migrations",
      username: "root",
      host: "localhost",
      encoding: "utf8",
      socket: "/tmp/mysql.sock"
    )

    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = Logger::INFO

    @adapter = ActiveRecord::Base.connection

    rebuild_table
  end

  def set_ar_setting(value)
    ActiveRecord::Base.stub(:mysql_online_migrations).and_return(value)
  end

  def teardown
    @adapter.drop_table :testing rescue nil
    ActiveRecord::Base.primary_key_prefix_type = nil
  end
end