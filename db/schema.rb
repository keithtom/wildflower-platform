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

ActiveRecord::Schema.define(version: 2021_11_17_190245) do

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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_identifier", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.index ["external_identifier"], name: "index_addresses_on_external_identifier", unique: true
  end

  create_table "people", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "journey_state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_identifier", null: false
    t.index ["email"], name: "index_people_on_email", unique: true
    t.index ["external_identifier"], name: "index_people_on_external_identifier", unique: true
  end

  create_table "person_experiences", force: :cascade do |t|
    t.bigint "person_id"
    t.string "type"
    t.string "name"
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.bigint "school_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_identifier", null: false
    t.index ["external_identifier"], name: "index_person_experiences_on_external_identifier", unique: true
    t.index ["person_id"], name: "index_person_experiences_on_person_id"
    t.index ["school_id"], name: "index_person_experiences_on_school_id"
  end

  create_table "person_roles", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "role_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_identifier", null: false
    t.index ["external_identifier"], name: "index_person_roles_on_external_identifier", unique: true
    t.index ["person_id"], name: "index_person_roles_on_person_id"
    t.index ["role_id"], name: "index_person_roles_on_role_id"
  end

  create_table "person_skills", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "skill_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_identifier", null: false
    t.index ["external_identifier"], name: "index_person_skills_on_external_identifier", unique: true
    t.index ["person_id"], name: "index_person_skills_on_person_id"
    t.index ["skill_id"], name: "index_person_skills_on_skill_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "old_name"
    t.string "website"
    t.string "phone"
    t.string "email"
    t.string "governance_type"
    t.string "tuition_assistance_type"
    t.string "ages_served"
    t.string "calendar"
    t.integer "max_enrollment"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_identifier", null: false
    t.index ["external_identifier"], name: "index_schools_on_external_identifier", unique: true
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at", precision: 6
    t.integer "person_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_identifier", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["external_identifier"], name: "index_users_on_external_identifier", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
