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

ActiveRecord::Schema[7.0].define(version: 2022_05_17_175723) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.string "line1"
    t.string "line2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_identifier", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.index ["external_identifier"], name: "index_addresses_on_external_identifier", unique: true
  end

  create_table "advice_decisions", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "state"
    t.string "title"
    t.text "context"
    t.text "proposal"
    t.text "links", default: [], array: true
    t.datetime "decide_by"
    t.datetime "advice_by"
    t.string "role"
    t.text "final_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_identifier", null: false
    t.index ["creator_id"], name: "index_advice_decisions_on_creator_id"
    t.index ["external_identifier"], name: "index_advice_decisions_on_external_identifier", unique: true
  end

  create_table "advice_events", force: :cascade do |t|
    t.bigint "decision_id"
    t.string "originator_type"
    t.bigint "originator_id"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decision_id"], name: "index_advice_events_on_decision_id"
  end

  create_table "advice_messages", force: :cascade do |t|
    t.bigint "decision_id"
    t.string "sender_type"
    t.bigint "sender_id"
    t.bigint "stakeholder_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_identifier", null: false
    t.index ["decision_id"], name: "index_advice_messages_on_decision_id"
    t.index ["external_identifier"], name: "index_advice_messages_on_external_identifier", unique: true
    t.index ["stakeholder_id"], name: "index_advice_messages_on_stakeholder_id"
  end

  create_table "advice_records", force: :cascade do |t|
    t.bigint "decision_id"
    t.bigint "stakeholder_id"
    t.text "content"
    t.string "status"
    t.string "impede_your_role"
    t.string "will_do_harm"
    t.string "harm_hard_to_reverse"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decision_id"], name: "index_advice_records_on_decision_id"
  end

  create_table "advice_stakeholders", force: :cascade do |t|
    t.bigint "decision_id"
    t.bigint "person_id"
    t.string "external_name"
    t.string "external_email"
    t.string "external_phone"
    t.string "external_calendar_url"
    t.string "external_roles"
    t.string "external_subroles"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_identifier", null: false
    t.index ["decision_id"], name: "index_advice_stakeholders_on_decision_id"
    t.index ["external_identifier"], name: "index_advice_stakeholders_on_external_identifier", unique: true
  end

  create_table "hubs", force: :cascade do |t|
    t.string "name"
    t.bigint "entrepreneur_id"
    t.string "external_identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entrepreneur_id"], name: "index_hubs_on_entrepreneur_id"
    t.index ["external_identifier"], name: "index_hubs_on_external_identifier", unique: true
    t.index ["name"], name: "index_hubs_on_name", unique: true
  end

  create_table "people", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "journey_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_identifier", null: false
    t.string "middle_name"
    t.string "personal_email"
    t.string "raw_address"
    t.string "airtable_id"
    t.bigint "hub_id"
    t.bigint "pod_id"
    t.text "about"
    t.string "tc_user_id"
    t.string "prosperworks_id"
    t.boolean "willing_to_relocate"
    t.string "primary_language"
    t.string "race_ethnicity_other"
    t.string "household_income"
    t.string "income_background"
    t.string "gender"
    t.string "gender_other"
    t.boolean "lgbtqia"
    t.string "pronouns"
    t.string "pronouns_other"
    t.string "airtable_partner_id"
    t.string "linkedin_url"
    t.index ["airtable_id"], name: "index_people_on_airtable_id", unique: true
    t.index ["email"], name: "index_people_on_email", unique: true
    t.index ["external_identifier"], name: "index_people_on_external_identifier", unique: true
    t.index ["hub_id"], name: "index_people_on_hub_id"
    t.index ["pod_id"], name: "index_people_on_pod_id"
  end

  create_table "people_relationships", force: :cascade do |t|
    t.bigint "person_id_id"
    t.bigint "other_person_id_id"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["other_person_id_id"], name: "index_people_relationships_on_other_person_id_id"
    t.index ["person_id_id"], name: "index_people_relationships_on_person_id_id"
  end

  create_table "pods", force: :cascade do |t|
    t.string "name"
    t.bigint "hub_id"
    t.bigint "primary_contact_id"
    t.string "external_identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_identifier"], name: "index_pods_on_external_identifier", unique: true
    t.index ["hub_id"], name: "index_pods_on_hub_id"
    t.index ["primary_contact_id"], name: "index_pods_on_primary_contact_id"
  end

  create_table "school_relationships", force: :cascade do |t|
    t.string "kind"
    t.bigint "school_id"
    t.bigint "person_id"
    t.string "name"
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_school_relationships_on_person_id"
    t.index ["school_id"], name: "index_school_relationships_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "old_name"
    t.string "website"
    t.string "phone"
    t.string "email"
    t.string "governance_type"
    t.string "ages_served"
    t.string "calendar"
    t.integer "max_enrollment"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_identifier", null: false
    t.bigint "pod_id"
    t.string "short_name"
    t.string "airtable_id"
    t.string "facebook"
    t.string "instagram"
    t.string "timezone"
    t.string "domain"
    t.string "logo_url"
    t.bigint "hub_id"
    t.string "raw_address"
    t.date "opened_on"
    t.string "facility_type"
    t.index ["airtable_id"], name: "index_schools_on_airtable_id", unique: true
    t.index ["external_identifier"], name: "index_schools_on_external_identifier", unique: true
    t.index ["hub_id"], name: "index_schools_on_hub_id"
    t.index ["pod_id"], name: "index_schools_on_pod_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_identifier", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["external_identifier"], name: "index_users_on_external_identifier", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "taggings", "tags"
end
