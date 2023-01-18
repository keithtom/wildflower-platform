class RemoveAssigneeIdFromWorkflowInstanceProcesses < ActiveRecord::Migration[7.0]
  def change
    remove_column :workflow_instance_processes, :assignee_id
    add_reference :workflow_instance_steps, :assignee, foreign_key: { to_table: :people }
  end
end
