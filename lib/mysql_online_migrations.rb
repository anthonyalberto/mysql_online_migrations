require 'active_record'
require "active_record/connection_adapters/mysql2_adapter"
require "mysql_online_migrations/columns"
require "mysql_online_migrations/indexes"

module MysqlOnlineMigrations
  include Indexes
  include Columns

  def self.included(base)
    ActiveRecord::Base.send(:class_attribute, :mysql_online_migrations, :instance_writer => false)
    ActiveRecord::Base.send("mysql_online_migrations=", true)
  end

  def lock_statement(lock, with_comma = false)
    return "" if lock == true
    return "" unless perform_migrations_online?
    puts "ONLINE MIGRATION"
    "#{with_comma ? ', ' : ''} LOCK=NONE"
  end

  def extract_lock_from_options(options)
    [options[:lock], options.except(:lock)]
  end

  def perform_migrations_online?
    ActiveRecord::Base.mysql_online_migrations == true
  end
end

ActiveRecord::ConnectionAdapters::Mysql2Adapter.send(:include, MysqlOnlineMigrations)