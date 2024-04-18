class AddTrackingStatsWorkflowDefinition < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_workflows, :rollout_started_at, :datetime
    add_column :workflow_definition_workflows, :rollout_completed_at, :datetime
    add_column :workflow_instance_workflows, :version, :string
  end
end
