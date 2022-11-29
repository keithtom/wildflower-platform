class RemoveResourceUrlAndResourceTitleFromWorkflowSteps < ActiveRecord::Migration[7.0]
  def change
    remove_column :workflow_definition_steps, :resource_url
    remove_column :workflow_definition_steps, :resource_title

    remove_column :workflow_instance_steps, :resource_url
    remove_column :workflow_instance_steps, :resource_title
  end
end
