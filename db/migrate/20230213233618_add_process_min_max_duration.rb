class AddProcessMinMaxDuration < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_processes, :min_worktime, :integer, default: 0
    add_column :workflow_definition_processes, :max_worktime, :integer, default: 0
    remove_column :workflow_definition_processes, :effort
    remove_column :workflow_instance_processes, :effort
  end
end
