class CreateTableWorkflowInstanceProcess < ActiveRecord::Migration[7.0]
  def change
    create_table :users, if_exists: false

    create_table :workflow_instance_processes do |t|
      t.belongs_to :workflow_definition_process, index: {:name => "index_table_workflow_inst_processes_on_workflow_def_process_id"}
      t.belongs_to :workflow_instance_workflow, index: {:name => "index_table_workflow_inst_processes_on_workflow_inst_workflow_id"}
      t.string :title
      t.text :description
      t.integer :weight # not sure if this should be effort
      t.integer :effort
      t.timestamp :started_at
      t.timestamp :completed_at
      t.references :assignee, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
