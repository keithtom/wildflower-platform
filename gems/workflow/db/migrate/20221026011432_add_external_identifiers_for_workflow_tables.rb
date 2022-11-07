class AddExternalIdentifiersForWorkflowTables < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_instance_workflows, :external_identifier, :string, null: false
    add_index :workflow_instance_workflows, :external_identifier, unique: true

    add_column :workflow_instance_processes, :external_identifier, :string, null: false
    add_index :workflow_instance_processes, :external_identifier, unique: true

    add_column :workflow_instance_steps, :external_identifier, :string, null: false
    add_index :workflow_instance_steps, :external_identifier, unique: true
  end
end
