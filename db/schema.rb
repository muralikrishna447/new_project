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

ActiveRecord::Schema.define(:version => 20151202012640) do

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
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "youtube_id"
    t.string   "difficulty"
    t.integer  "cooked_this",            :default => 0
    t.string   "yield"
    t.text     "timing"
    t.text     "description"
    t.integer  "activity_order"
    t.boolean  "published",              :default => false
    t.string   "slug"
    t.text     "transcript"
    t.text     "image_id"
    t.text     "featured_image_id"
    t.string   "activity_type"
    t.integer  "last_edited_by_id"
    t.integer  "source_activity_id"
    t.integer  "source_type",            :default => 0
    t.text     "assignment_recipes"
    t.datetime "published_at"
    t.text     "author_notes"
    t.integer  "likes_count"
    t.integer  "currently_editing_user"
    t.boolean  "include_in_gallery",     :default => true
    t.integer  "creator",                :default => 0
    t.boolean  "show_only_in_course",    :default => false
    t.string   "summary_tweet"
    t.string   "vimeo_id"
    t.text     "short_description"
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

  create_table "activity_ingredients", :force => true do |t|
    t.integer  "activity_id",      :null => false
    t.integer  "ingredient_id",    :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "unit"
    t.decimal  "quantity"
    t.integer  "ingredient_order"
    t.string   "display_quantity"
    t.string   "note"
  end

  add_index "activity_ingredients", ["activity_id"], :name => "index_activity_ingredients_on_activity_id"
  add_index "activity_ingredients", ["ingredient_id"], :name => "index_activity_ingredients_on_ingredient_id"
  add_index "activity_ingredients", ["ingredient_order"], :name => "index_activity_ingredients_on_ingredient_order"

  create_table "actor_addresses", :force => true do |t|
    t.string   "actor_type",                               :null => false
    t.integer  "actor_id",                                 :null => false
    t.string   "address_id"
    t.string   "client_metadata"
    t.integer  "sequence",        :default => 0,           :null => false
    t.string   "ip_address"
    t.string   "status",          :default => "something"
    t.integer  "issued_at"
    t.integer  "expires_at"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "unique_key"
  end

  add_index "actor_addresses", ["actor_id"], :name => "index_actor_addresses_on_actor_id"
  add_index "actor_addresses", ["actor_type", "actor_id", "unique_key"], :name => "index_actor_addresses_on_actor_type_and_actor_id_and_unique_key", :unique => true
  add_index "actor_addresses", ["address_id"], :name => "index_actor_addresses_on_address_id"

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

  create_table "assemblies", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "image_id"
    t.string   "youtube_id"
    t.string   "assembly_type",                                           :default => "Assembly"
    t.string   "slug"
    t.integer  "likes_count"
    t.integer  "comments_count"
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
    t.boolean  "published"
    t.datetime "published_at"
    t.decimal  "price",                     :precision => 8, :scale => 2
    t.integer  "badge_id"
    t.boolean  "show_prereg_page_in_index",                               :default => false
    t.text     "short_description"
    t.text     "upload_copy"
    t.text     "buy_box_extra_bullets"
    t.text     "preview_copy"
    t.text     "testimonial_copy"
    t.text     "prereg_image_id"
    t.string   "prereg_email_list_id"
    t.text     "description_alt"
    t.string   "vimeo_id"
    t.boolean  "premium",                                                 :default => false
  end

  create_table "assembly_inclusions", :force => true do |t|
    t.string   "includable_type"
    t.integer  "includable_id"
    t.integer  "assembly_id"
    t.integer  "position"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "include_disqus",  :default => true
  end

  add_index "assembly_inclusions", ["assembly_id"], :name => "index_assembly_inclusions_on_assembly_id"
  add_index "assembly_inclusions", ["includable_id", "includable_type"], :name => "index_assembly_inclusions_on_includable_id_and_includable_type"

  create_table "assignments", :force => true do |t|
    t.integer  "activity_id"
    t.integer  "child_activity_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "title"
    t.text     "description"
    t.string   "slug"
  end

  add_index "assignments", ["activity_id", "child_activity_id"], :name => "index_assignments_on_activity_id_and_child_activity_id"

  create_table "badges_sashes", :force => true do |t|
    t.integer  "badge_id"
    t.integer  "sash_id"
    t.boolean  "notified_user", :default => false
    t.datetime "created_at"
  end

  add_index "badges_sashes", ["badge_id", "sash_id"], :name => "index_badges_sashes_on_badge_id_and_sash_id"
  add_index "badges_sashes", ["badge_id"], :name => "index_badges_sashes_on_badge_id"
  add_index "badges_sashes", ["sash_id"], :name => "index_badges_sashes_on_sash_id"

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

  create_table "circulator_users", :force => true do |t|
    t.integer "user_id"
    t.integer "circulator_id"
    t.boolean "owner"
  end

  add_index "circulator_users", ["user_id", "circulator_id"], :name => "index_circulator_users_on_user_id_and_circulator_id", :unique => true

  create_table "circulators", :force => true do |t|
    t.string   "serial_number"
    t.string   "notes"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "circulator_id",                      :null => false
    t.string   "encrypted_secret_key", :limit => 64
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "rating"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"

  create_table "components", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "component_type"
    t.hstore   "meta"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "component_parent_type"
    t.integer  "component_parent_id"
    t.integer  "position"
  end

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
    t.boolean  "published",         :default => false
    t.decimal  "course_order"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "short_description"
    t.text     "image_id"
    t.text     "additional_script"
    t.string   "youtube_id"
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "enrollable_id"
    t.string   "enrollable_type"
    t.decimal  "price",               :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "sales_tax",           :precision => 8, :scale => 2, :default => 0.0
    t.integer  "gift_certificate_id"
    t.datetime "trial_expires_at"
  end

  add_index "enrollments", ["enrollable_type", "enrollable_id", "user_id"], :name => "enrollable_user_index", :unique => true

  create_table "equipment", :force => true do |t|
    t.string   "title"
    t.string   "product_url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "viewed",         :default => false
    t.string   "group_type"
    t.text     "group_name"
    t.boolean  "published",      :default => false
  end

  add_index "events", ["action", "trackable_type", "trackable_id"], :name => "index_events_on_action_and_trackable_type_and_trackable_id"
  add_index "events", ["action"], :name => "index_events_on_action"
  add_index "events", ["group_name"], :name => "index_events_on_group_name"
  add_index "events", ["group_type"], :name => "index_events_on_group_type"
  add_index "events", ["trackable_type", "trackable_id"], :name => "index_events_on_trackable_type_and_trackable_id"
  add_index "events", ["trackable_type"], :name => "index_events_on_trackable_type"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "followerships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "follower_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "followerships", ["follower_id"], :name => "index_followerships_on_follower_id"
  add_index "followerships", ["user_id"], :name => "index_followerships_on_user_id"

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "gift_certificates", :force => true do |t|
    t.integer  "purchaser_id"
    t.string   "recipient_email",                                  :default => "",    :null => false
    t.string   "recipient_name",                                   :default => "",    :null => false
    t.text     "recipient_message",                                :default => ""
    t.integer  "assembly_id"
    t.decimal  "price",              :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "sales_tax",          :precision => 8, :scale => 2, :default => 0.0
    t.string   "token"
    t.boolean  "redeemed",                                         :default => false
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.boolean  "followed_up",                                      :default => false
    t.boolean  "email_to_recipient"
  end

  add_index "gift_certificates", ["token"], :name => "index_gift_certificates_on_token"

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
    t.string  "title"
  end

  add_index "inclusions", ["activity_id", "course_id"], :name => "index_inclusions_on_activity_id_and_course_id"
  add_index "inclusions", ["course_id", "activity_id"], :name => "index_inclusions_on_course_id_and_activity_id"

  create_table "ingredients", :force => true do |t|
    t.string   "title"
    t.string   "product_url"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "for_sale",        :default => false
    t.integer  "sub_activity_id"
    t.decimal  "density"
    t.string   "slug"
    t.text     "image_id"
    t.string   "youtube_id"
    t.text     "text_fields"
    t.integer  "comments_count",  :default => 0
    t.string   "vimeo_id"
  end

  add_index "ingredients", ["slug"], :name => "index_ingredients_on_slug"

  create_table "likes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "likeable_id"
    t.string   "likeable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "merit_actions", :force => true do |t|
    t.integer  "user_id"
    t.string   "action_method"
    t.integer  "action_value"
    t.boolean  "had_errors",    :default => false
    t.string   "target_model"
    t.integer  "target_id"
    t.boolean  "processed",     :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "merit_activity_logs", :force => true do |t|
    t.integer  "action_id"
    t.string   "related_change_type"
    t.integer  "related_change_id"
    t.string   "description"
    t.datetime "created_at"
  end

  create_table "merit_score_points", :force => true do |t|
    t.integer  "score_id"
    t.integer  "num_points", :default => 0
    t.string   "log"
    t.datetime "created_at"
  end

  create_table "merit_scores", :force => true do |t|
    t.integer "sash_id"
    t.string  "category", :default => "default"
  end

  create_table "order_sort_images", :force => true do |t|
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "slug"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "likes_count"
    t.text     "image_id"
    t.string   "primary_path"
    t.text     "short_description"
    t.boolean  "show_footer",       :default => false
    t.boolean  "published",         :default => false
  end

  create_table "pg_search_documents", :force => true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "poll_items", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "status"
    t.integer  "poll_id"
    t.integer  "votes_count",    :default => 0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "comments_count", :default => 0
  end

  create_table "polls", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "slug"
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "image_id"
    t.datetime "closed_at"
  end

  create_table "premium_gift_certificates", :force => true do |t|
    t.integer  "purchaser_id"
    t.decimal  "price",        :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "sales_tax",    :precision => 8, :scale => 2, :default => 0.0
    t.string   "token"
    t.boolean  "redeemed",                                   :default => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  add_index "premium_gift_certificates", ["token"], :name => "index_premium_gift_certificates_on_token"

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
    t.text     "start_copy"
    t.text     "end_copy"
    t.boolean  "published",   :default => false
  end

  add_index "quizzes", ["activity_id"], :name => "index_quizzes_on_activity_id"
  add_index "quizzes", ["slug"], :name => "index_quizzes_on_slug", :unique => true

  create_table "revision_records", :force => true do |t|
    t.string   "revisionable_type", :limit => 100,                    :null => false
    t.integer  "revisionable_id",                                     :null => false
    t.integer  "revision",                                            :null => false
    t.binary   "data"
    t.datetime "created_at",                                          :null => false
    t.boolean  "trash",                            :default => false
  end

  add_index "revision_records", ["revisionable_id"], :name => "revision_records_id"
  add_index "revision_records", ["revisionable_type", "created_at", "trash"], :name => "revision_records_type_and_created_at"

  create_table "sashes", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "settings", :force => true do |t|
    t.string   "footer_image"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
    t.integer  "featured_activity_1_id"
    t.integer  "featured_activity_2_id"
    t.integer  "featured_activity_3_id"
    t.text     "global_message"
    t.boolean  "global_message_active",                                  :default => false
    t.boolean  "forum_maintenance"
    t.string   "hero_cms_title",                                         :default => ""
    t.text     "hero_cms_image",                                         :default => ""
    t.text     "hero_cms_description",                                   :default => ""
    t.string   "hero_cms_button_text",                                   :default => ""
    t.string   "hero_cms_url",                                           :default => ""
    t.decimal  "premium_membership_price", :precision => 8, :scale => 2
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
    t.string   "note"
  end

  add_index "step_ingredients", ["ingredient_id"], :name => "index_step_ingredients_on_ingredient_id"
  add_index "step_ingredients", ["ingredient_order"], :name => "index_step_ingredients_on_ingredient_order"
  add_index "step_ingredients", ["step_id"], :name => "index_step_ingredients_on_step_id"

  create_table "steps", :force => true do |t|
    t.text     "title"
    t.integer  "activity_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "youtube_id"
    t.integer  "step_order"
    t.text     "directions"
    t.text     "image_id"
    t.text     "transcript"
    t.string   "image_description"
    t.string   "subrecipe_title"
    t.string   "audio_clip"
    t.string   "audio_title"
    t.boolean  "hide_number"
    t.boolean  "is_aside"
    t.text     "presentation_hints", :default => "{}"
    t.text     "extra"
    t.string   "vimeo_id"
  end

  add_index "steps", ["activity_id"], :name => "index_steps_on_activity_id"
  add_index "steps", ["step_order"], :name => "index_steps_on_step_order"

  create_table "stripe_events", :force => true do |t|
    t.string   "event_id"
    t.string   "object"
    t.string   "api_version"
    t.string   "request_id"
    t.string   "event_type"
    t.integer  "created"
    t.datetime "event_at"
    t.boolean  "livemode"
    t.text     "data"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "processed",   :default => false
  end

  create_table "stripe_orders", :force => true do |t|
    t.string   "idempotency_key"
    t.integer  "user_id"
    t.text     "data"
    t.boolean  "submitted",       :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "uploads", :force => true do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "image_id"
    t.text     "notes"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "course_id"
    t.boolean  "approved",       :default => false
    t.integer  "likes_count"
    t.string   "slug"
    t.integer  "comments_count", :default => 0
    t.integer  "assembly_id"
  end

  create_table "user_activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.string   "action"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                                       :default => "",    :null => false
    t.string   "encrypted_password",                                          :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                               :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                                     :null => false
    t.datetime "updated_at",                                                                     :null => false
    t.string   "name",                                                        :default => "",    :null => false
    t.string   "provider"
    t.string   "facebook_user_id"
    t.string   "location",                                                    :default => ""
    t.string   "website",                                                     :default => ""
    t.text     "quote",                                                       :default => ""
    t.string   "chef_type",                                                   :default => "",    :null => false
    t.string   "slug"
    t.boolean  "from_aweber"
    t.text     "viewed_activities"
    t.string   "signed_up_from"
    t.text     "image_id"
    t.text     "bio"
    t.integer  "sash_id"
    t.integer  "level",                                                       :default => 0
    t.string   "role"
    t.string   "stripe_id"
    t.string   "authentication_token"
    t.string   "google_refresh_token"
    t.string   "google_access_token"
    t.string   "google_user_id"
    t.integer  "referrer_id"
    t.string   "referred_from"
    t.hstore   "survey_results"
    t.integer  "events_count"
    t.string   "twitter_user_id"
    t.string   "twitter_auth_token"
    t.string   "twitter_user_name"
    t.boolean  "signup_incentive_available",                                  :default => true
    t.boolean  "timf_incentive_available",                                    :default => true
    t.boolean  "premium_member",                                              :default => false
    t.datetime "premium_membership_created_at"
    t.decimal  "premium_membership_price",      :precision => 8, :scale => 2, :default => 0.0
    t.boolean  "used_circulator_discount",                                    :default => false
    t.boolean  "needs_special_terms",                                         :default => false
    t.datetime "deleted_at"
    t.datetime "first_joule_purchased_at"
    t.integer  "joule_purchase_count",                                        :default => 0
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["survey_results"], :name => "index_users_on_survey_results"

  create_table "versions", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "version"
  end

  add_index "versions", ["version"], :name => "index_versions_on_version"

  create_table "videos", :force => true do |t|
    t.string   "youtube_id"
    t.string   "title"
    t.string   "description"
    t.boolean  "featured"
    t.boolean  "filmstrip"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "image_id"
  end

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "votable_id"
    t.string   "votable_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

end
