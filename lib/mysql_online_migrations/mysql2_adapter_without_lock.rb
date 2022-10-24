module ActiveRecord
  module ConnectionAdapters
    class Mysql2AdapterWithoutLock < Mysql2Adapter

      OPTIMIZABLE_DDL_REGEX = /^(alter|create (unique )? ?index|drop index) /i
      DDL_WITH_COMMA_REGEX = /^alter /i
      DDL_WITH_LOCK_NONE_REGEX = / LOCK=NONE\s*$/i

      def initialize(mysql2_adapter, verbose = false)
        @verbose = verbose
        params = [:@connection, :@logger, :@connection_options, :@config].map do |sym|
          mysql2_adapter.instance_variable_get(sym)
        end
        super(*params)
      end

      alias_method :original_execute, :execute
      def execute(sql, name = nil)
        new_sql = apply_lock_none_if_needed(sql)
        original_execute(new_sql, name)
      rescue ActiveRecord::StatementInvalid => e
        if e.message =~ /Cannot change column type INPLACE/
          original_execute(sql, name)
        else
          raise e
        end
      end

      def apply_lock_none_if_needed(sql)
        return sql unless sql =~ OPTIMIZABLE_DDL_REGEX
        "#{sql} #{lock_none_statement(sql)}"
      end

      def lock_none_statement(sql)
        return "" unless ActiveRecord::Base.mysql_online_migrations
        return "" if sql =~ DDL_WITH_LOCK_NONE_REGEX
        comma_delimiter = (sql =~ DDL_WITH_COMMA_REGEX ? "," : "")
        puts "ONLINE MIGRATION" if @verbose
        "#{comma_delimiter} LOCK=NONE"
      end
    end
  end
end
