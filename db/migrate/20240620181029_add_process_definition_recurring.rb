class AddProcessDefinitionRecurring < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_processes, :recurring, :boolean, default: false
    add_column :workflow_definition_processes, :recurring_type, :integer
    add_column :workflow_definition_processes, :due_date, :datetime
    add_column :workflow_instance_processes, :due_date, :datetime
  end
end
