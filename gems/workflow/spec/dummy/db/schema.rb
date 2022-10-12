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

ActiveRecord::Schema[7.0].define(version: 2022_10_11_211841) do
  create_table "table_workflow_instance_processes", force: :cascade do |t|
    t.integer "workflow_definition_process_id"
    t.integer "workflow_instance_workflow_id"
    t.string "title"
    t.text "description"
    t.integer "weight"
    t.integer "effort", default: 0
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.integer "assignee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_table_workflow_instance_processes_on_assignee_id"
    t.index ["workflow_definition_process_id"], name: "index_table_workflow_inst_processes_on_workflow_def_process_id"
    t.index ["workflow_instance_workflow_id"], name: "index_table_workflow_inst_processes_on_workflow_inst_workflow_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "workflow_definition_dependencies", force: :cascade do |t|
    t.integer "workflow_id"
    t.string "workable_type"
    t.integer "workable_id"
    t.string "prequisite_workable_type"
    t.integer "prequisite_workable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prequisite_workable_type", "prequisite_workable_id"], name: "index_workflow_definition_dependencies_on_prequisite_workable"
    t.index ["workable_type", "workable_id"], name: "index_workflow_definition_dependencies_on_workable"
    t.index ["workflow_id"], name: "index_workflow_definition_dependencies_on_workflow_id"
  end

  create_table "workflow_definition_processes", force: :cascade do |t|
    t.string "version"
    t.string "title"
    t.text "description"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "effort", default: 0
  end

  create_table "workflow_definition_selected_processes", force: :cascade do |t|
    t.integer "workflow_id"
    t.integer "process_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["process_id"], name: "index_workflow_definition_selected_processes_on_process_id"
    t.index ["workflow_id"], name: "index_workflow_definition_selected_processes_on_workflow_id"
  end

  create_table "workflow_definition_steps", force: :cascade do |t|
    t.integer "process_id"
    t.string "name"
    t.text "description"
    t.string "kind"
    t.integer "weight"
    t.string "url"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["process_id"], name: "index_workflow_definition_steps_on_process_id"
  end

  create_table "workflow_definition_workflows", force: :cascade do |t|
    t.string "version"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workflow_instance_workflows", force: :cascade do |t|
    t.integer "workflow_definition_workflow_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_definition_workflow_id"], name: "index_workflow_instance_workflows_on_workflow_def_workflow_id"
  end

  add_foreign_key "table_workflow_instance_processes", "users", column: "assignee_id"
  add_foreign_key "taggings", "tags"
end
