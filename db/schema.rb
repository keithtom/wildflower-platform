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

ActiveRecord::Schema[7.0].define(version: 2023_06_01_190738) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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
    t.datetime "decide_by"
    t.datetime "advice_by"
    t.string "role"
    t.text "final_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_identifier", null: false
    t.text "changes_summary"
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
    t.string "external_image_url"
    t.index ["decision_id"], name: "index_advice_stakeholders_on_decision_id"
    t.index ["external_identifier"], name: "index_advice_stakeholders_on_external_identifier", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.string "documentable_type"
    t.bigint "documentable_id"
    t.string "inheritance_type"
    t.string "title"
    t.string "link"
    t.string "external_identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable"
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
    t.string "image_url"
    t.string "primary_language_other"
    t.string "montessori_certified"
    t.datetime "affiliated_at"
    t.boolean "show_ssj", default: false
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
    t.string "external_identifier"
    t.index ["external_identifier"], name: "index_school_relationships_on_external_identifier", unique: true
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
    t.string "hero_image_url"
    t.index ["airtable_id"], name: "index_schools_on_airtable_id", unique: true
    t.index ["external_identifier"], name: "index_schools_on_external_identifier", unique: true
    t.index ["hub_id"], name: "index_schools_on_hub_id"
    t.index ["pod_id"], name: "index_schools_on_pod_id"
  end

  create_table "ssj_team_members", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "ssj_team_id"
    t.string "role"
    t.string "status"
    t.index ["person_id"], name: "index_ssj_team_members_on_person_id"
    t.index ["ssj_team_id"], name: "index_ssj_team_members_on_ssj_team_id"
  end

  create_table "ssj_teams", force: :cascade do |t|
    t.string "external_identifier", null: false
    t.bigint "workflow_id"
    t.date "expected_start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ops_guide_id"
    t.bigint "regional_growth_lead_id"
    t.index ["external_identifier"], name: "index_ssj_teams_on_external_identifier", unique: true
    t.index ["ops_guide_id"], name: "index_ssj_teams_on_ops_guide_id"
    t.index ["regional_growth_lead_id"], name: "index_ssj_teams_on_regional_growth_lead_id"
    t.index ["workflow_id"], name: "index_ssj_teams_on_workflow_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
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
    t.string "jti", null: false
    t.string "authentication_token", limit: 30
    t.datetime "authentication_token_created_at"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["external_identifier"], name: "index_users_on_external_identifier", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workflow_decision_options", force: :cascade do |t|
    t.bigint "decision_id"
    t.string "description"
    t.string "external_identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decision_id"], name: "index_workflow_decision_options_on_decision_id"
    t.index ["external_identifier"], name: "index_workflow_decision_options_on_external_identifier", unique: true
  end

  create_table "workflow_definition_dependencies", force: :cascade do |t|
    t.bigint "workflow_id"
    t.string "workable_type"
    t.bigint "workable_id"
    t.string "prerequisite_workable_type"
    t.bigint "prerequisite_workable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prerequisite_workable_type", "prerequisite_workable_id"], name: "index_workflow_definition_dependencies_on_prerequisite_workable"
    t.index ["workable_type", "workable_id"], name: "index_workflow_definition_dependencies_on_workable"
    t.index ["workflow_id"], name: "index_workflow_definition_dependencies_on_workflow_id"
  end

  create_table "workflow_definition_processes", force: :cascade do |t|
    t.string "version"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
  end

  create_table "workflow_definition_selected_processes", force: :cascade do |t|
    t.bigint "workflow_id"
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["process_id"], name: "index_workflow_definition_selected_processes_on_process_id"
    t.index ["workflow_id"], name: "index_workflow_definition_selected_processes_on_workflow_id"
  end

  create_table "workflow_definition_steps", force: :cascade do |t|
    t.bigint "process_id"
    t.string "title"
    t.text "description"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "min_worktime", default: 0
    t.integer "max_worktime", default: 0
    t.string "completion_type"
    t.string "decision_question"
    t.index ["process_id"], name: "index_workflow_definition_steps_on_process_id"
  end

  create_table "workflow_definition_workflows", force: :cascade do |t|
    t.string "version"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workflow_instance_dependencies", force: :cascade do |t|
    t.bigint "definition_id"
    t.bigint "workflow_id"
    t.string "workable_type"
    t.bigint "workable_id"
    t.string "prerequisite_workable_type"
    t.bigint "prerequisite_workable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["definition_id"], name: "index_workflow_instance_dependencies_on_definition_id"
    t.index ["prerequisite_workable_type", "prerequisite_workable_id"], name: "index_workflow_instance_dependencies_on_prerequisite_workable"
    t.index ["workable_type", "workable_id"], name: "index_workflow_instance_dependencies_on_workable"
    t.index ["workflow_id"], name: "index_workflow_instance_dependencies_on_workflow_id"
  end

  create_table "workflow_instance_processes", force: :cascade do |t|
    t.bigint "definition_id"
    t.bigint "workflow_id"
    t.string "title"
    t.text "description"
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.string "external_identifier", null: false
    t.bigint "steps_count"
    t.integer "completed_steps_count", default: 0, null: false
    t.integer "completion_status", default: 0
    t.integer "dependency_cache", default: 0
    t.index ["definition_id"], name: "index_workflow_instance_processes_on_definition_id"
    t.index ["external_identifier"], name: "index_workflow_instance_processes_on_external_identifier", unique: true
    t.index ["workflow_id"], name: "index_workflow_instance_processes_on_workflow_id"
  end

  create_table "workflow_instance_step_assignments", force: :cascade do |t|
    t.bigint "step_id", null: false
    t.bigint "assignee_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "selected_option_id"
    t.index ["assignee_id"], name: "index_workflow_instance_step_assignments_on_assignee_id"
    t.index ["step_id"], name: "index_workflow_instance_step_assignments_on_step_id"
  end

  create_table "workflow_instance_steps", force: :cascade do |t|
    t.bigint "process_id"
    t.bigint "definition_id"
    t.string "title"
    t.string "kind"
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.string "external_identifier", null: false
    t.boolean "assigned", default: false
    t.string "completion_type"
    t.text "description"
    t.integer "min_worktime"
    t.integer "max_worktime"
    t.string "decision_question"
    t.index ["definition_id"], name: "index_workflow_instance_steps_on_definition_id"
    t.index ["external_identifier"], name: "index_workflow_instance_steps_on_external_identifier", unique: true
    t.index ["process_id"], name: "index_workflow_instance_steps_on_process_id"
  end

  create_table "workflow_instance_workflows", force: :cascade do |t|
    t.bigint "definition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_identifier", null: false
    t.string "current_phase", default: "visioning"
    t.index ["definition_id"], name: "index_workflow_instance_workflows_on_definition_id"
    t.index ["external_identifier"], name: "index_workflow_instance_workflows_on_external_identifier", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ssj_team_members", "ssj_teams"
  add_foreign_key "ssj_teams", "people", column: "ops_guide_id"
  add_foreign_key "ssj_teams", "people", column: "regional_growth_lead_id"
  add_foreign_key "ssj_teams", "workflow_instance_workflows", column: "workflow_id"
  add_foreign_key "taggings", "tags"
  add_foreign_key "workflow_instance_step_assignments", "workflow_instance_steps", column: "step_id"
end
