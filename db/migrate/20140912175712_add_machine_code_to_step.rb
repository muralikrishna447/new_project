class AddMachineCodeToStep < ActiveRecord::Migration
  def change
    add_column :steps, :extra, :text
  end
end
