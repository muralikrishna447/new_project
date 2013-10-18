class AddViewedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :viewed, :boolean, default: false
  end
end
