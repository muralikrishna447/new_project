class CreateUserAcquisitions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_acquisitions do |t|
      t.integer :user_id
      t.string :signup_method
      t.string :landing_page
      t.string :referrer
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :utm_term
      t.string :utm_content
      t.string :gclid

      t.timestamps
    end
  end
end
