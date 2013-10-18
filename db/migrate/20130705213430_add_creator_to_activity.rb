class AddCreatorToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :creator, :integer, default: 0
  end
end
