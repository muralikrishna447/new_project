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

ActiveRecord::Schema.define(:version => 20130111211249) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "activities", :force => true do |t|
    t.string   "title"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "youtube_id"
    t.string   "difficulty"
    t.integer  "cooked_this",    :default => 0
    t.string   "yield"
    t.text     "timing"
    t.text     "description"
    t.integer  "activity_order"
    t.boolean  "published",      :default => false
    t.string   "slug"
  end

  add_index "activities", ["activity_order"], :name => "index_activities_on_activity_order"
  add_index "activities", ["slug"], :name => "index_activities_on_slug", :unique => true

  create_table "activity_equipment", :force => true do |t|
    t.integer  "activity_id",                        :null => false
    t.integer  "equipment_id",                       :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "optional",        :default => false
    t.integer  "equipment_order"
  end

  add_index "activity_equipment", ["activity_id", "equipment_id"], :name => "activity_equipment_index", :unique => true
  add_index "activity_equipment", ["equipment_order"], :name => "index_activity_equipment_on_equipment_order"

  create_table "activity_recipe_steps", :force => true do |t|
    t.integer  "activity_id", :null => false
    t.integer  "step_id",     :null => false
    t.integer  "step_order"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "activity_recipe_steps", ["activity_id", "step_id"], :name => "index_activity_recipe_steps_on_activity_id_and_step_id", :unique => true
  add_index "activity_recipe_steps", ["step_order"], :name => "index_activity_recipe_steps_on_step_order"

  create_table "activity_recipes", :force => true do |t|
    t.integer  "activity_id",  :null => false
    t.integer  "recipe_id",    :null => false
    t.integer  "recipe_order"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "activity_recipes", ["activity_id", "recipe_id"], :name => "index_activity_recipes_on_activity_id_and_recipe_id", :unique => true
  add_index "activity_recipes", ["recipe_order"], :name => "index_activity_recipes_on_recipe_order"

  create_table "admin_users", :force => true do |t|
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

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "answers", :force => true do |t|
    t.integer  "question_id",                    :null => false
    t.integer  "user_id",                        :null => false
    t.string   "type"
    t.text     "contents"
    t.boolean  "correct",     :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "answers", ["question_id", "user_id"], :name => "index_answers_on_question_id_and_user_id", :unique => true

  create_table "box_sort_images", :force => true do |t|
    t.integer  "question_id",                        :null => false
    t.boolean  "key_image",       :default => false
    t.text     "key_explanation", :default => ""
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "image_order"
  end

  add_index "box_sort_images", ["image_order"], :name => "index_box_sort_images_on_image_order"
  add_index "box_sort_images", ["question_id"], :name => "index_box_sort_images_on_question_id"

  create_table "copies", :force => true do |t|
    t.string   "location"
    t.text     "copy"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "copies", ["location"], :name => "index_copies_on_location"

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.boolean  "published",    :default => false
    t.decimal  "course_order"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "equipment", :force => true do |t|
    t.string   "title"
    t.string   "product_url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "images", :force => true do |t|
    t.string   "filename"
    t.string   "url"
    t.string   "caption"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "inclusions", :force => true do |t|
    t.integer "course_id"
    t.integer "activity_id"
    t.decimal "activity_order"
    t.integer "nesting_level",  :default => 1
  end

  add_index "inclusions", ["activity_id", "course_id"], :name => "index_inclusions_on_activity_id_and_course_id"
  add_index "inclusions", ["course_id", "activity_id"], :name => "index_inclusions_on_course_id_and_activity_id"

  create_table "ingredients", :force => true do |t|
    t.string   "title"
    t.string   "product_url"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "for_sale",    :default => false
  end

  create_table "order_sort_images", :force => true do |t|
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "private_tokens", :force => true do |t|
    t.string   "token",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "questions", :force => true do |t|
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "quiz_id"
    t.string   "type"
    t.text     "contents",               :default => ""
    t.integer  "question_order"
    t.integer  "answer_count",           :default => 0
    t.integer  "correct_answer_count",   :default => 0
    t.integer  "incorrect_answer_count", :default => 0
  end

  add_index "questions", ["question_order"], :name => "index_questions_on_question_order"

  create_table "quiz_sessions", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "quiz_id",                       :null => false
    t.boolean  "completed",  :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "quiz_sessions", ["user_id", "quiz_id"], :name => "index_quiz_sessions_on_user_id_and_quiz_id", :unique => true

  create_table "quizzes", :force => true do |t|
    t.string   "title"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "activity_id"
    t.string   "slug"
    t.string   "start_copy"
    t.string   "end_copy"
    t.boolean  "published",   :default => false
  end

  add_index "quizzes", ["activity_id"], :name => "index_quizzes_on_activity_id"
  add_index "quizzes", ["slug"], :name => "index_quizzes_on_slug", :unique => true

  create_table "recipe_ingredients", :force => true do |t|
    t.integer  "recipe_id",        :null => false
    t.integer  "ingredient_id",    :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "unit"
    t.decimal  "quantity"
    t.integer  "ingredient_order"
    t.string   "display_quantity"
  end

  add_index "recipe_ingredients", ["ingredient_order"], :name => "index_recipe_ingredients_on_ingredient_order"
  add_index "recipe_ingredients", ["recipe_id", "ingredient_id"], :name => "index_recipe_ingredients_on_recipe_id_and_ingredient_id", :unique => true

  create_table "recipes", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "yield"
  end

  create_table "step_ingredients", :force => true do |t|
    t.integer  "step_id",          :null => false
    t.integer  "ingredient_id",    :null => false
    t.decimal  "quantity"
    t.string   "unit"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "ingredient_order"
    t.string   "display_quantity"
  end

  add_index "step_ingredients", ["ingredient_order"], :name => "index_step_ingredients_on_ingredient_order"
  add_index "step_ingredients", ["step_id", "ingredient_id"], :name => "index_step_ingredients_on_step_id_and_ingredient_id", :unique => true

  create_table "steps", :force => true do |t|
    t.string   "title"
    t.integer  "activity_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "youtube_id"
    t.integer  "step_order"
    t.integer  "recipe_id"
    t.text     "directions"
    t.string   "image_id"
  end

  add_index "steps", ["activity_id"], :name => "index_steps_on_activity_id"
  add_index "steps", ["recipe_id"], :name => "index_steps_on_recipe_id"
  add_index "steps", ["step_order"], :name => "index_steps_on_step_order"

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
    t.string   "name",                   :default => "", :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "location",               :default => ""
    t.string   "website",                :default => ""
    t.text     "quote",                  :default => ""
    t.string   "chef_type",              :default => "", :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "version"
  end

  add_index "versions", ["version"], :name => "index_versions_on_version"

end
