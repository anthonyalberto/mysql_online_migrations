def reset_queries_collectors
  @queries_received_by_regular_adapter = []
  @queries_received_by_adapter_without_lock = []
end

shared_examples_for "a migration that adds LOCK=NONE when needed" do
  before(:each) do
    stub_adapter_without_lock
    stub_execute(@adapter, :execute, :regular_execute)
    stub_execute(@adapter_without_lock, :original_execute, :execute_without_lock)
    @migration_arguments = migration_arguments + migration_arguments_with_lock
  end

  it "executes the same query as the original adapter, with LOCK=NONE when required" do
    @migration_arguments.each do |migration_argument|
      reset_queries_collectors

      begin
        @adapter.public_send(method_name, *migration_argument)
      rescue => e
        raise e unless @rescue_statement_when_stubbed
      end

      begin
        build_migration(method_name, migration_argument).migrate(:up)
      rescue => e
        raise e unless @rescue_statement_when_stubbed
      end

      @queries_received_by_regular_adapter.length.should > 0
      @queries_received_by_regular_adapter.length.should == @queries_received_by_adapter_without_lock.length
      @queries_received_by_regular_adapter.each_with_index do |query, index|
        @queries_received_by_adapter_without_lock[index].should == add_lock_none(query, comma_before_lock_none)
      end
    end
  end
end

shared_examples_for "a migration that succeeds in MySQL" do
  it "succeeds without exception" do
    set_ar_setting(false) if ENV["TRAVIS"] # Travis doesn't run MySQL 5.6 ...
    migration_arguments.each do |migration_argument|
      migration = build_migration(method_name, migration_argument)
      migration.migrate(:up)
      rebuild_table
    end
    set_ar_setting(true)
  end
end

shared_examples_for "a migration with a non-lockable statement" do
  it "raises a MySQL exception" do
    set_ar_setting(false) if ENV["TRAVIS"]
    migration_arguments_with_lock.each do |migration_argument|
      migration = build_migration(method_name, migration_argument)
      begin
        migration.migrate(:up)
      rescue ActiveRecord::StatementInvalid => e
        e.message.should =~ /LOCK=NONE is not supported/
      end
      rebuild_table
    end
    set_ar_setting(true) if ENV["TRAVIS"]
  end
end