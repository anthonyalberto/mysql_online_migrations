module MysqlOnlineMigrations
  module Indexes
    def add_index(table_name, column_name, options = {})
      lock = options.delete(:lock)
      index_name, index_type, index_columns = add_index_options(table_name, column_name, options)
      execute "CREATE #{index_type} INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)} (#{index_columns}) #{lock_statement(lock)}"
    end

    def remove_index(table_name, options_index_name, options = {})
      lock = options.delete(:lock)
      execute "DROP INDEX #{quote_column_name(index_name_for_remove(table_name, options_index_name))} ON #{quote_table_name(table_name)} #{lock_statement(lock)}"
    end

    def rename_index(table_name, old_name, new_name, options = {})
      old_index_def = indexes(table_name).detect { |i| i.name == old_name }
      return unless old_index_def
      lock = options[:lock]
      remove_index(table_name, { :name => old_name }, options)
      add_index(table_name, old_index_def.columns, options.merge(name: new_name, unique: old_index_def.unique, lock: lock))
    end
  end
end