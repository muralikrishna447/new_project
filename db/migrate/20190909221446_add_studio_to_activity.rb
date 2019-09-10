class AddStudioToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :studio, :boolean, default: false
  end
end
