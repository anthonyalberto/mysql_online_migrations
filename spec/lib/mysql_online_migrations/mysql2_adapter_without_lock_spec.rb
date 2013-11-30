require "spec_helper"

describe ActiveRecord::ConnectionAdapters::Mysql2AdapterWithoutLock do
  context "#initialize" do
    it "successfully instantiates a working adapter" do

    end
  end

  context "#lock_none_statement" do
    context "with mysql_online_migrations set to true" do
      context "with alter" do
        let(:query) { "alter " }
        it "adds ', LOCK=NONE'" do

        end
      end
      context "with drop index" do
        let(:query) { "drop index " }
        it "adds ' LOCK=NONE'" do

        end
      end
      context "with create index" do
        let(:query) { "create index " }
        it "adds ' LOCK=NONE'" do

        end
      end
    end

    context "with mysql_online_migrations set to false" do
      it "doesn't add anything to the request" do

      end
    end
  end

  context "#execute" do
    shared_examples_for "#execute that changes the SQL" do

    end

    shared_examples_for "#execute that doesn't change the SQL" do

    end

    context "with an optimizable DDL statement" do
      context "with alter" do
        let(:query) { "alter " }
        it_behaves_like "#execute that changes the SQL"
      end
      context "with drop index" do
        let(:query) { "drop index " }
        it_behaves_like "#execute that changes the SQL"
      end
      context "with create" do
        let(:query) { "create index " }
        it_behaves_like "#execute that changes the SQL"
      end
    end

    context "with other DDL statements" do
      context "with create table" do
        let(:query) { "create table " }
        it_behaves_like "#execute that doesn't change the SQL"
      end

      context "with drop table" do
        let(:query) { "drop table " }
        it_behaves_like "#execute that doesn't change the SQL"
      end
    end

    context "with a regular statement" do
      context "with select" do
        let(:query) { "select " }
        it_behaves_like "#execute that doesn't change the SQL"
      end

      context "with set" do
        let(:query) { "set " }
        it_behaves_like "#execute that doesn't change the SQL"
      end

      context "with insert" do
        let(:query) { "insert " }
        it_behaves_like "#execute that doesn't change the SQL"
      end

      context "with update" do
        let(:query) { "update " }
        it_behaves_like "#execute that doesn't change the SQL"
      end

      context "with delete" do
        let(:query) { "delete " }
        it_behaves_like "#execute that doesn't change the SQL"
      end

      context "with show" do
        let(:query) { "show " }
        it_behaves_like "#execute that doesn't change the SQL"
      end

      context "with explain" do
        let(:query) { "explain " }
        it_behaves_like "#execute that doesn't change the SQL"
      end
    end
  end
end