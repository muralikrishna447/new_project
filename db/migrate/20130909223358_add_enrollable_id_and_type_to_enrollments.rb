class AddEnrollableIdAndTypeToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :enrollable_id, :integer
    add_column :enrollments, :enrollable_type, :string
  end
end
