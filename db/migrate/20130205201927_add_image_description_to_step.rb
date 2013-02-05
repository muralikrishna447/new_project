class AddImageDescriptionToStep < ActiveRecord::Migration
  def change
    add_column :steps, :image_description, :string
  end
end
