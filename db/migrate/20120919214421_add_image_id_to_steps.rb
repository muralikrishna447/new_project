class AddImageIdToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :image_id, :string
  end
end
