class AddCompletedAtWorkflowInstanceSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_instance_steps, :completed_at, :datetime
  end
end
