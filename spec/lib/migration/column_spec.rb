require "spec_helper"

describe ActiveRecord::Migration do
  let(:comma_before_lock_none) { true }
  let(:migration_arguments_with_lock) { [] }

  context "#add_column" do
    let(:method_name) { :add_column }
    let(:migration_arguments) do
      [
        [:testing, :foo2, :string],
        [:testing, :foo2, :string, { limit: 20, null: false, default: 'def' }],
        [:testing, :foo2, :decimal, { precision:3, scale: 2 }]
      ]
    end

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#add_timestamps" do
    let(:migration_arguments) do
      [
        [:testing2]
      ]
    end

    let(:method_name) { :add_timestamps }

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#remove_column" do
    let(:migration_arguments) do
      [
        [:testing, :foo],
        [:testing, :foo, :bar]
      ]
    end

    let(:method_name) { :remove_column }

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#remove_timestamps" do
    let(:migration_arguments) do
      [
        [:testing]
      ]
    end

    let(:method_name) { :remove_timestamps }

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#change_column" do
    let(:migration_arguments) do
      # Unsupported with lock=none : change column type, change limit, set NOT NULL.
      [
        [:testing, :foo, :string, { default: 'def', limit: 100 }],
        [:testing, :foo, :string, { null: true, limit: 100 }]
      ]
    end

    let(:migration_arguments_with_lock) do
      [
        [:testing, :foo, :string, { limit: 200 }],
        [:testing, :foo, :string, { default: 'def' }],
        [:testing, :foo, :string, { null: false }],
        [:testing, :foo, :string, { null: false, default: 'def', limit: 200 }],
        [:testing, :foo, :string, { null: true }],
        [:testing, :foo, :integer, { null: true, limit: 6 }],
        [:testing, :foo, :integer, { null: true, limit: 1 }]
      ]
    end

    let(:method_name) { :change_column }

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
    it_behaves_like "a migration with a non-lockable statement"
  end

  context "#change_column_default" do
    let(:migration_arguments) do
      [
        [:testing, :foo, 'def'],
        [:testing, :foo, nil]
      ]
    end

    let(:method_name) { :change_column_default }

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#change_column_null" do
    let(:migration_arguments) do
      #change_column_null doesn't set DEFAULT in sql. It just issues an update statement before setting the NULL value if setting NULL to false
      [
        [:testing, :bam, true, nil],
        [:testing, :bam, true, 'def']
      ]
    end

    let(:migration_arguments_with_lock) do
      [
        [:testing, :bam, false, nil],
        [:testing, :bam, false, 'def']
      ]
    end

    let(:method_name) { :change_column_null }

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
    it_behaves_like "a migration with a non-lockable statement"
  end

  context "#rename_column" do
    let(:migration_arguments) do
      [
        [:testing, :foo, :foo2]
      ]
    end

    let(:method_name) { :rename_column }

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end
end