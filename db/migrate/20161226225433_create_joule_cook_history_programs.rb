class CreateJouleCookHistoryPrograms < ActiveRecord::Migration
  def change
    create_table :joule_cook_history_programs do |t|
      t.string :guide_id
      t.string :cook_id
      t.integer :timer_id
      t.string :history_item_type
      t.string :program_id
      t.float :set_point
      t.float :holding_temperature
      t.integer :cook_time
      t.integer :cook_history_item_id
      t.integer :delayed_start
      t.boolean :wait_for_preheat
      t.boolean :predictive
      t.timestamps
    end
  end
end
