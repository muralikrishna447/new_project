class AddImageIdToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :image_id, :string
  end
end
