# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120910222521) do

  create_table "activities", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "video_url"
  end

  create_table "activity_equipment", :force => true do |t|
    t.integer  "activity_id",  :null => false
    t.integer  "equipment_id", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "activity_equipment", ["activity_id", "equipment_id"], :name => "activity_equipment_index", :unique => true

  create_table "activity_ingredients", :force => true do |t|
    t.integer  "activity_id",   :null => false
    t.integer  "ingredient_id", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "quantity"
  end

  add_index "activity_ingredients", ["activity_id", "ingredient_id"], :name => "index_activity_ingredients_on_activity_id_and_ingredient_id", :unique => true

  create_table "equipment", :force => true do |t|
    t.string   "title"
    t.boolean  "optional"
    t.string   "product_url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "ingredients", :force => true do |t|
    t.string   "title"
    t.string   "product_url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "steps", :force => true do |t|
    t.string   "title"
    t.integer  "activity_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "video_url"
    t.integer  "step_order"
  end

  add_index "steps", ["activity_id"], :name => "index_steps_on_activity_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
