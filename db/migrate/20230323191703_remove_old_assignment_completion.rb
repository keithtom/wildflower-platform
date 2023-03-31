class RemoveOldAssignmentCompletion < ActiveRecord::Migration[7.0]
  def change
    remove_column :workflow_instance_steps, :assignee_id

    remove_column :workflow_instance_steps, :completed
    remove_column :workflow_instance_steps, :completed_at

    add_column :workflow_instance_step_assignments, :selected_option_id, :bigint
    remove_column :workflow_instance_steps, :selected_option_id
  end
end
