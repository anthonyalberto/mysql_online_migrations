require 'active_record'
require "mysql_online_migrations/columns"
require "mysql_online_migrations/indexes"
require "active_record/connection_adapters/mysql2_adapter"
require "active_record/connection_adapters/abstract_mysql_adapter"

module MysqlOnlineMigrations
  include Indexes
  include Columns

  def self.included(base)
    base.extend ClassMethods
  end

  def lock_statement(lock)
    return "" if lock == true
    return "" if defined?(Rails) && Rails.application.config.active_record.mysql_online_migrations == false
    puts "ONLINE MIGRATION"
    " LOCK=NONE"
  end

  module ClassMethods
  end
end

ActiveRecord::ConnectionAdapters::Mysql2Adapter.send(:include, MysqlOnlineMigrations)