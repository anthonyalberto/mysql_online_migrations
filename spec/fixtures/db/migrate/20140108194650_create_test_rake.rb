class CreateTestRake < ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration::Current : ActiveRecord::Migration
  def change
    create_table :test_rake
  end
end
