class AddTypeToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :activity_type, :string
  end
end
