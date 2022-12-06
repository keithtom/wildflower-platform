class RemoveDefaultEffort < ActiveRecord::Migration[7.0]
  def change
    change_column_default :workflow_definition_processes, :effort, nil
  end
end
