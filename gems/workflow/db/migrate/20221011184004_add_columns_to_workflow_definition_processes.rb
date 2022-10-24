class AddColumnsToWorkflowDefinitionProcesses < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_processes, :effort, :integer, default: 0
    rename_column :workflow_definition_processes, :name, :title
  end
end
