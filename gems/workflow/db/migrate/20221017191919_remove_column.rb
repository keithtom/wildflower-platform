class RemoveColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :workflow_instance_processes, :weight
    remove_column :workflow_definition_processes, :weight
    remove_column :workflow_definition_steps, :weight

    add_column :workflow_definition_steps, :position, :integer
    add_column :workflow_instance_steps, :position, :integer

    add_column :workflow_definition_processes, :position, :integer
    add_column :workflow_instance_processes, :position, :integer
  end
end
