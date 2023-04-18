class RemoveOldAssignmentCompletion < ActiveRecord::Migration[7.0]
  def change
    remove_column :workflow_instance_steps, :assignee_id, :bigint
    remove_column :workflow_instance_steps, :completed_at, :datetime
    add_column :workflow_instance_steps, :assigned, :boolean, default: false
    change_column :workflow_instance_steps, :completed, :boolean, default: false

    add_column :workflow_instance_step_assignments, :selected_option_id, :bigint
    remove_column :workflow_instance_steps, :selected_option_id, :bigint
  end
end
