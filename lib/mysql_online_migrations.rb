require 'active_record'
require "active_record/migration"
require "active_record/connection_adapters/mysql2_adapter"

%w(*.rb).each do |path|
  Dir["#{File.dirname(__FILE__)}/mysql_online_migrations/#{path}"].each { |f| require(f) }
end

module MysqlOnlineMigrations

  class << self; attr_accessor :verbose; end

  def self.prepended(base)
    ActiveRecord::Base.send(:class_attribute, :mysql_online_migrations, :instance_writer => false)
    ActiveRecord::Base.send("mysql_online_migrations=", true)
  end

  def connection
    original_connection = super
    adapter_mode = original_connection.class.name == "ActiveRecord::ConnectionAdapters::Mysql2Adapter"

    @original_adapter ||= if adapter_mode
      original_connection
    else
      original_connection.instance_variable_get(:@delegate)
    end

    @no_lock_adapter ||= ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock.new(@original_adapter, MysqlOnlineMigrations.verbose)

    if adapter_mode
      @no_lock_adapter
    else
      original_connection.instance_variable_set(:@delegate, @no_lock_adapter)
      original_connection
    end
  end

  def with_lock
    original_value = ActiveRecord::Base.mysql_online_migrations
    ActiveRecord::Base.mysql_online_migrations = false
    yield
    ActiveRecord::Base.mysql_online_migrations = original_value
  end

end

ActiveRecord::Migration.send(:prepend, MysqlOnlineMigrations)
