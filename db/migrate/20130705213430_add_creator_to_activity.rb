class AddCreatorToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :creator, :integer, default: 0
  end
end
