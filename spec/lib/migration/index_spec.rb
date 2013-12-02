require "spec_helper"

describe ActiveRecord::Migration do
  let(:comma_before_lock_none) { false }
  let(:migration_arguments_with_lock) { [] }
  context "#add_index" do
    let(:method_name) { :add_index }
    let(:migration_arguments) do
      [
        [:testing, :foo],
        [:testing, :foo, { length: 10 }],
        [:testing, [:foo, :bar, :baz], {}],
        [:testing, [:foo, :bar, :baz], { unique: true }],
        [:testing, [:foo, :bar, :baz], { unique: true, name: "best_index_of_the_world" }]
      ]
    end

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#remove_index" do
    let(:method_name) { :remove_index }
    let(:migration_arguments) do
      [
        [:testing, :baz],
        [:testing, [:bar, :baz]],
        [:testing, { column: [:bar, :baz] }],
        [:testing, { name: "best_index_of_the_world2" }]
      ]
    end

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end

  context "#rename_index" do
    let(:method_name) { :rename_index }
    let(:migration_arguments) do
      [
        [:testing, "best_index_of_the_world2", "renamed_best_index_of_the_world2"],
        [:testing, "best_index_of_the_world3", "renamed_best_index_of_the_world3"]
      ]
    end

    it_behaves_like "a migration that adds LOCK=NONE when needed"
    it_behaves_like "a migration that succeeds in MySQL"
  end
end