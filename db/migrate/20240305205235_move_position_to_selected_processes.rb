class MovePositionToSelectedProcesses < ActiveRecord::Migration[7.0]
  def change
    remove_column :workflow_definition_processes, :position
    add_column :workflow_definition_selected_processes, :position, :integer
  end
end
