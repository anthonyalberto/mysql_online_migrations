module MysqlOnlineMigrations
  module Columns
    def add_column(table_name, column_name, type, options = {})
      lock, options = extract_lock_from_options(options)
      execute("ALTER TABLE #{quote_table_name(table_name)} #{add_column_sql(table_name, column_name, type, options)} #{lock_statement(lock, true)}")
    end

    def add_timestamps(table_name, options = {})
      add_column table_name, :created_at, :datetime, options
      add_column table_name, :updated_at, :datetime, options
    end

    def change_column(table_name, column_name, type, options = {})
      lock, options = extract_lock_from_options(options)
      execute("ALTER TABLE #{quote_table_name(table_name)} #{change_column_sql(table_name, column_name, type, options)} #{lock_statement(lock, true)}")
    end

    def rename_column(table_name, column_name, new_column_name, options = {})
      lock, options = extract_lock_from_options(options)
      execute("ALTER TABLE #{quote_table_name(table_name)} #{rename_column_sql(table_name, column_name, new_column_name)} #{lock_statement(lock, true)}")
    end

    def remove_column(table_name, *column_names)
      if column_names.flatten!
        message = 'Passing array to remove_columns is deprecated, please use ' +
                  'multiple arguments, like: `remove_columns(:posts, :foo, :bar)`'
        ActiveSupport::Deprecation.warn message, caller
      end

      lock, options = if column_names.last.is_a? Hash
        options = column_names.last
        column_names = column_names[0..-2]
        extract_lock_from_options(options)
      else
        [false, {}]
      end

      columns_for_remove(table_name, *column_names).each do |column_name|
        execute "ALTER TABLE #{quote_table_name(table_name)} DROP #{column_name} #{lock_statement(lock, true)}"
      end
    end

    def remove_timestamps(table_name, options = {})
      remove_column table_name, :updated_at, options
      remove_column table_name, :created_at, options
    end
  end
end