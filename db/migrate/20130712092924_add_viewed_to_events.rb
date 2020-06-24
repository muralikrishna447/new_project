class AddViewedToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :viewed, :boolean, default: false
  end
end
