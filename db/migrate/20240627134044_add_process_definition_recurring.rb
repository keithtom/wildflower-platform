class AddProcessDefinitionRecurring < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_workflows, :recurring, :boolean, default: false
    add_column :workflow_definition_processes, :recurring, :boolean, default: false
    add_column :workflow_definition_processes, :due_months, :integer, array: true
    add_column :workflow_definition_processes, :duration, :integer
    add_column :workflow_instance_processes, :suggested_start_date, :date
    add_column :workflow_instance_processes, :due_date, :date
    add_column :workflow_instance_processes, :recurring_type, :string
  end
end
