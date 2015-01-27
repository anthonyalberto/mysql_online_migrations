require "spec_helper"

RSpec.describe ActiveRecord::Migration do
  OLD_VERSION = "20120508133018"
  NEW_VERSION = "20150119090054"

  let(:comma_before_lock_none) { true }
  let(:migration_arguments_with_lock) { [] }

  context "#create_table" do
    let(:method_name) { :create_table }
    let(:migration_arguments) do
      [
        [:test5]
      ]
    end

    context "when version ignore rule is configured" do
      before { set_ignore_setting -> (version) { version < NEW_VERSION } }

      context "when version matches" do
        it_behaves_like "a migration that does not modify statement", OLD_VERSION
        it_behaves_like "a migration that succeeds in MySQL", OLD_VERSION
      end

      context "when version does not match" do
        it_behaves_like "a migration that adds LOCK=NONE when needed", NEW_VERSION
        it_behaves_like "a migration that succeeds in MySQL", NEW_VERSION
      end
    end
  end
end
