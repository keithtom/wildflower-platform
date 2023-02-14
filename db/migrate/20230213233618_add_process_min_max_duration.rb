class AddProcessMinMaxDuration < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_steps, :min_worktime, :integer, default: 0
    add_column :workflow_definition_steps, :max_worktime, :integer, default: 0
    remove_column :workflow_definition_processes, :effort, :integer
    remove_column :workflow_instance_processes, :effort, :integer
  end
end
