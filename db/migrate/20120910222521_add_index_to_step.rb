class AddIndexToStep < ActiveRecord::Migration[5.2]
  def change
    add_index(:steps, :activity_id)
  end
end
