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

ActiveRecord::Schema[7.0].define(version: 2022_08_06_035158) do
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
    t.string "name"
    t.text "description"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "name"
    t.string "version"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
