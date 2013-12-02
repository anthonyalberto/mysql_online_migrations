require "spec_helper"

describe ActiveRecord::Migration do
  let(:comma_before_lock_none) { true }
  let(:migration_arguments_with_lock) { [] }

  context "#create_table" do
    let(:method_name) { :create_table }
    let(:migration_arguments) do
      [
        [:test5]
      ]
    end

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#drop_table" do
    let(:method_name) { :drop_table }
    let(:migration_arguments) do
      [
        [:testing]
      ]
    end

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#rename_table" do
    let(:method_name) { :rename_table }
    let(:migration_arguments) do
      [
        [:testing, :testing20]
      ]
    end

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end
end