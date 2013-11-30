require 'active_record'
require "active_record/migration"
require "active_record/connection_adapters/mysql2_adapter"

%w(*.rb).each do |path|
  Dir["#{File.dirname(__FILE__)}/mysql_online_migrations/#{path}"].each { |f| require(f) }
end

module MysqlOnlineMigrations
  def self.prepended(base)
    ActiveRecord::Base.send(:class_attribute, :mysql_online_migrations, :instance_writer => false)
    ActiveRecord::Base.send("mysql_online_migrations=", true)
  end

  def connection
    @no_lock_adapter ||= ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock.new(super)
  end

  def with_lock
    original_value = ActiveRecord::Base.mysql_online_migrations
    ActiveRecord::Base.mysql_online_migrations = false
    yield
    ActiveRecord::Base.mysql_online_migrations = original_value
  end
end

ActiveRecord::Migration.send(:prepend, MysqlOnlineMigrations)