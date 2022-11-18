# This migration comes from workflow (originally 20221115184357)
class AddCompletedAtWorkflowInstanceSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_instance_steps, :completed_at, :datetime
  end
end
