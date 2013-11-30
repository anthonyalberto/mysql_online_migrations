module ActiveRecord
  module ConnectionAdapters
    class Mysql2AdapterWithoutLock < Mysql2Adapter
      def initialize(mysql2_adapter)
        params = [:@connection, :@logger, :@connection_options, :@config].map do |sym|
          mysql2_adapter.instance_variable_get(sym)
        end
        super(*params)
      end

      alias_method :original_execute, :execute
      def execute(sql, name = nil)
        if sql =~ /^(alter|create (unique)?   index|drop index) /i
          sql = "#{sql} #{lock_none_statement(sql)}"
          puts "EXECUTING #{sql}"
        end
        original_execute(sql, name)
      end

      def lock_none_statement(sql)
        return sql unless ActiveRecord::Base.mysql_online_migrations
        comma_delimiter = (sql =~ /^alter /i ? "," : "")
        "#{comma_delimiter} LOCK=NONE"
      end
    end
  end
end