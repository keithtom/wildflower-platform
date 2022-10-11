class CreateWorkflowInstanceWorkflows < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_instance_workflows do |t|
      t.belongs_to :workflow_definition_workflow, index: {:name => "index_workflow_instance_workflows_on_workflow_def_workflow_id"}

      t.timestamps
    end
  end
end
