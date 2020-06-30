class CreateStripeEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_events do |t|
      t.string :event_id, :object, :api_version, :request_id, :event_type
      t.integer :created
      t.datetime :event_at
      t.boolean :livemode
      t.text :data
      t.timestamps null: false
      t.boolean :processed, default: false
    end
  end
end
