class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.timestamps
    end
  end
end
