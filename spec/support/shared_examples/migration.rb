def reset_queries_collectors
  @queries_received_by_regular_adapter = []
  @queries_received_by_adapter_without_lock = []
end

def staged_for_travis
  set_ar_setting(false) if ENV["TRAVIS"] # Travis doesn't run MySQL 5.6. Run tests locally first.
  yield
  set_ar_setting(true) if ENV["TRAVIS"]
end

shared_examples_for "a migration that adds LOCK=NONE when needed" do |version=nil|
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
        build_migration(method_name, migration_argument, version).migrate(:up)
      rescue => e
        raise e unless @rescue_statement_when_stubbed
      end

      expect(@queries_received_by_regular_adapter.length).to be > 0
      expect(@queries_received_by_regular_adapter.length).to eq(@queries_received_by_adapter_without_lock.length)
      @queries_received_by_regular_adapter.each_with_index do |query, index|
        expect(@queries_received_by_adapter_without_lock[index]).to eq(add_lock_none(query, comma_before_lock_none))
      end
    end
  end
end

shared_examples_for "a migration that does not modify statement" do |version=nil|
  before(:each) do
    stub_adapter_without_lock
    stub_execute(@adapter, :execute, :regular_execute)
    stub_execute(@adapter_without_lock, :original_execute, :execute_without_lock)
    @migration_arguments = migration_arguments + migration_arguments_with_lock
  end

  it "executes the same query as the original adapter unmodified" do
    @migration_arguments.each do |migration_argument|
      reset_queries_collectors

      begin
        @adapter.public_send(method_name, *migration_argument)
      rescue => e
        raise e unless @rescue_statement_when_stubbed
      end

      begin
        build_migration(method_name, migration_argument, version).migrate(:up)
      rescue => e
        raise e unless @rescue_statement_when_stubbed
      end

      expect(@queries_received_by_regular_adapter.length).to be > 0
      expect(@queries_received_by_adapter_without_lock.length).to eq(0)

      size = @queries_received_by_regular_adapter.count
      @queries_received_by_regular_adapter.each_with_index do |query, index|
        expect(@queries_received_by_regular_adapter[size - index - 1]).to eq(query)
      end
    end
  end
end

shared_examples_for "a migration that succeeds in MySQL" do |version=nil|
  it "succeeds without exception" do
    staged_for_travis do
      migration_arguments.each do |migration_argument|
        migration = build_migration(method_name, migration_argument, version)
        migration.migrate(:up)
        rebuild_table
      end
    end
  end
end

shared_examples_for "a migration with a non-lockable statement" do |version=nil|
  it "raises a MySQL exception" do
    staged_for_travis do
      migration_arguments_with_lock.each do |migration_argument|
        migration = build_migration(method_name, migration_argument, version)
        begin
          migration.migrate(:up)
        rescue ActiveRecord::StatementInvalid => e
          expect(e.message).to match(/LOCK=NONE is not supported/)
        end
        rebuild_table
      end
    end
  end
end
