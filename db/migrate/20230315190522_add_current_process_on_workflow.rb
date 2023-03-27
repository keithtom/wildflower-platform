class AddCurrentProcessOnWorkflow < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_instance_workflows, :current_phase, :string, default: Workflow::Definition::Process::VISIONING
  end
end
