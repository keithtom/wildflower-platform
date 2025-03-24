class AddVisibleToWorkflowInstanceWorkflows < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_instance_workflows, :visible, :boolean, null: false, default: true
  end
end 