class CreateJouleCookHistoryPrograms < ActiveRecord::Migration
  def change
    create_table :joule_cook_history_programs do |t|
      t.string :guide_id
      t.string :cook_id
      t.integer :timer_id
      t.string :program_type
      t.integer :set_point
      t.integer :holding_temperature
      t.integer :cook_time
      t.integer :cook_history_item_id
      t.timestamps
    end
  end
end
