class AddMachineCodeToStep < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :extra, :text
  end
end
