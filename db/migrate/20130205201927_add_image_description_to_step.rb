class AddImageDescriptionToStep < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :image_description, :string
  end
end
