class AddIndexToStep < ActiveRecord::Migration
  def change
    add_index(:steps, :activity_id)
  end
end
