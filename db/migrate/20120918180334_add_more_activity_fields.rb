class AddMoreActivityFields < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :difficulty, :string
    add_column :activities, :cooked_this_count, :integer, default: 0
    add_column :activities, :yield, :string
    add_column :activities, :timing, :text
  end
end
