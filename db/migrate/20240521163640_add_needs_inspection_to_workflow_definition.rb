class AddNeedsInspectionToWorkflowDefinition < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_workflows, :needs_support, :boolean, default: false
  end
end
