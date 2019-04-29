class CreateJouleReadySurveysSent < ActiveRecord::Migration
  def change
    create_table :joule_ready_surveys_sent, id: false do |t|
      t.string :program_id
      t.integer :user_id
      t.string :name
      t.string :email
      t.string :guide_id
      t.string :cook_id
      t.string :sku
      t.string :collector_url
      t.column :email_sent_at, 'timestamp without time zone'
    end

    add_index :joule_ready_surveys_sent, [:email, :guide_id], unique: true
  end
end
