# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_05_16_154031) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversations", force: :cascade do |t|
    t.bigint "team_id"
    t.datetime "last_message_at", precision: nil
    t.string "uuid"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "last_message_id"
    t.bigint "document_id"
    t.index ["document_id"], name: "index_conversations_on_document_id"
    t.index ["last_message_id"], name: "index_conversations_on_last_message_id"
    t.index ["team_id"], name: "index_conversations_on_team_id"
  end

  create_table "conversations_messages", force: :cascade do |t|
    t.bigint "conversation_id"
    t.bigint "message_id"
    t.bigint "membership_id"
    t.string "author_name"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_message_id"
    t.string "participant_type"
    t.bigint "participant_id"
    t.index ["conversation_id"], name: "index_conversations_messages_on_conversation_id"
    t.index ["membership_id"], name: "index_conversations_messages_on_membership_id"
    t.index ["message_id"], name: "index_conversations_messages_on_message_id"
    t.index ["parent_message_id"], name: "index_conversations_messages_on_parent_message_id"
    t.index ["participant_type", "participant_id"], name: "index_conversations_messages_on_participant"
  end

  create_table "conversations_read_receipts", force: :cascade do |t|
    t.bigint "membership_id"
    t.bigint "conversation_id"
    t.datetime "last_read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_conversations_read_receipts_on_conversation_id"
    t.index ["membership_id"], name: "index_conversations_read_receipts_on_membership_id"
  end

  create_table "conversations_subscriptions", force: :cascade do |t|
    t.bigint "membership_id"
    t.bigint "conversation_id"
    t.datetime "unsubscribed_at"
    t.datetime "last_read_at"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_conversations_subscriptions_on_conversation_id"
    t.index ["membership_id"], name: "index_conversations_subscriptions_on_membership_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "team_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_customers_on_team_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_documents_on_team_id"
  end

  create_table "invitations", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "uuid"
    t.integer "from_membership_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "team_id"
    t.index ["team_id"], name: "index_invitations_on_team_id"
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "team_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "invitation_id"
    t.string "user_first_name"
    t.string "user_last_name"
    t.string "user_profile_photo_id"
    t.string "user_email"
    t.bigint "added_by_id"
    t.bigint "platform_agent_of_id"
    t.jsonb "role_ids", default: []
    t.index ["added_by_id"], name: "index_memberships_on_added_by_id"
    t.index ["invitation_id"], name: "index_memberships_on_invitation_id"
    t.index ["platform_agent_of_id"], name: "index_memberships_on_platform_agent_of_id"
    t.index ["team_id"], name: "index_memberships_on_team_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "scaffolding_absolutely_abstract_creative_concepts", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_scaffold_absolutely_abstract_creative_concept_on_team_id"
  end

  create_table "scaffolding_absolutely_abstract_creative_concepts_collaborators", force: :cascade do |t|
    t.jsonb "role_ids"
    t.bigint "creative_concept_id", null: false
    t.bigint "membership_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creative_concept_id"], name: "index_creative_concepts_collaborators_on_creative_concept_id"
    t.index ["membership_id"], name: "index_creative_concepts_collaborators_on_membership_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "being_destroyed"
    t.string "time_zone"
    t.string "locale"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "current_team_id"
    t.string "first_name"
    t.string "last_name"
    t.string "time_zone"
    t.datetime "last_seen_at", precision: nil
    t.string "profile_photo_id"
    t.jsonb "ability_cache"
    t.datetime "last_notification_email_sent_at", precision: nil
    t.boolean "former_user", default: false, null: false
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.string "otp_backup_codes", array: true
    t.string "locale"
    t.bigint "platform_agent_of_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "conversations", "conversations_messages", column: "last_message_id"
  add_foreign_key "conversations", "documents"
  add_foreign_key "conversations", "teams"
  add_foreign_key "conversations_messages", "conversations"
  add_foreign_key "conversations_messages", "conversations_messages", column: "message_id"
  add_foreign_key "conversations_messages", "conversations_messages", column: "parent_message_id"
  add_foreign_key "conversations_messages", "memberships"
  add_foreign_key "conversations_read_receipts", "conversations"
  add_foreign_key "conversations_read_receipts", "memberships"
  add_foreign_key "conversations_subscriptions", "conversations"
  add_foreign_key "conversations_subscriptions", "memberships"
  add_foreign_key "documents", "teams"
  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users"
  add_foreign_key "scaffolding_absolutely_abstract_creative_concepts", "teams"
  add_foreign_key "scaffolding_absolutely_abstract_creative_concepts_collaborators", "scaffolding_absolutely_abstract_creative_concepts", column: "creative_concept_id"
end
