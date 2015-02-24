if defined?(Octopus)
  module Octopus
    class ProxyWithoutLock < Proxy
      OPTIMIZABLE_DDL_REGEX = /^(alter|create (unique )? ?index|drop index) /i
      DDL_WITH_COMMA_REGEX = /^alter /i
      DDL_WITH_LOCK_NONE_REGEX = / LOCK=NONE\s*$/i

      def initialize(config = Octopus.config, verbose = false)
        @verbose = verbose
        super(config)
      end

      alias_method :original_execute, :execute
      def execute(sql, name = nil)
        if sql =~ OPTIMIZABLE_DDL_REGEX
          sql = "#{sql} #{lock_none_statement(sql)}"
        end
        original_execute(sql, name)
      end

      def lock_none_statement(sql)
        return "" unless ActiveRecord::Base.mysql_online_migrations
        return "" if sql =~ DDL_WITH_LOCK_NONE_REGEX
        comma_delimiter = (sql =~ DDL_WITH_COMMA_REGEX ? "," : "")
        puts "ONLINE MIGRATION"
        "#{comma_delimiter} LOCK=NONE"
      end
    end
  end
end