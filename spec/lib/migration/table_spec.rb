require "spec_helper"

describe ActiveRecord::Migration do
  context "#create_table" do
    let(:method_name) { :create_table }
    let(:queries) do
      {
        [:test5] => []
      }
    end

    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#drop_table" do
    let(:method_name) { :drop_table }
    let(:queries) do
      {
        [:testing] => []
      }
    end

    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#rename_table" do
    let(:method_name) { :rename_table }
    let(:queries) do
      {
        [:testing, :testing20] => []
      }
    end

    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#change_table" do
    let(:bulk) { false }
    let(:migration) do
      build_migration(:change_table, [:testing, bulk: bulk]) do |t|
        t.column :nametest, :string, :limit => 60
        t.column :nametest2, :string, :limit => 60
      end
    end
    after(:each) do
      rebuild_table
    end

    it "generates statements with LOCK=NONE" do
      stub_original_execute
      stub_adapter_without_lock

      should_receive(:execute).with("ALTER TABLE `testing` ADD `nametest` varchar(60) , LOCK=NONE")
      should_receive(:execute).with("ALTER TABLE `testing` ADD `nametest2` varchar(60) , LOCK=NONE")

      migration.migrate(:up)
    end

    it "succeeds" do
      migration.migrate(:up)
    end

    context "in bulk" do
      let(:bulk) { true }

      it "generates the statement with LOCK=NONE" do
        stub_original_execute
        stub_adapter_without_lock
        should_receive(:execute).with("ALTER TABLE `testing` ADD `nametest` varchar(60), ADD `nametest2` varchar(60) , LOCK=NONE")
        migration.migrate(:up)
      end

      it "succeeds" do
        migration.migrate(:up)
      end
    end
  end
end