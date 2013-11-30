shared_examples_for "a migration that adds LOCK=NONE when needed" do
  before(:each) do
    stub_adapter_without_lock
    stub_original_execute
  end

  context "migrate up" do
    it "sends each command with LOCK=NONE at the end to original_execute" do
      queries.each do |args, sql|
        migration = build_migration(method_name, args)
        Array.wrap(sql).each { |statement| should_receive(:execute).with(add_lock_none(statement, comma_before_lock_none)) }
        migration.migrate(:up)
      end
    end
  end

  context "migrate down" do
    it "adds LOCK=NONE to the statement when needed" do
      queries.each do |args, sql|
        migration = build_migration(method_name, args)
        should_receive(:execute).with(/ LOCK=NONE\s*$/i).at_least(1)
        migration.migrate(:down)
      end
    end
  end
  it "succeeds rolling it back" do
    @adapter_without_lock.stub(:original_execute)
  end
end

shared_examples_for "a migration that succeeds in MySQL" do
  shared_examples_for "migrate in a direction that succeeds" do
    it "succeeds without exception" do
      queries.each do |args, _|
        migration = build_migration(method_name, args)
        migration.migrate(direction)
        rebuild_table
      end
    end
  end

  context "migrate up" do
    let(:direction) { :up }

    it_behaves_like "migrate in a direction that succeeds"
  end

  # context "migrate down" do
  #   let(:direction) { :down }

  #   it_behaves_like "migrate in a direction that succeeds"
  # end
end

shared_examples_for "a migration with a non-lockable statement" do
  it "raises a MySQL exception" do
    queries_with_lock.each do |args, _|
      migration = build_migration(method_name, args)

      begin
        migration.migrate(:up)
      rescue ActiveRecord::StatementInvalid => e
        e.message.should =~ /LOCK=NONE is not supported/
      end
      rebuild_table
    end
  end
end