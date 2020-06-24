class AddStudioToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :studio, :boolean, default: false
  end
end
