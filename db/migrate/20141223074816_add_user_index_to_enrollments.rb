class AddUserIndexToEnrollments < ActiveRecord::Migration[5.2]
  def change
    add_index :enrollments, [:enrollable_type, :enrollable_id, :user_id], unique: true, name: "enrollable_user_index"
  end
end
