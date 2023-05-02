class RemoveUnused < ActiveRecord::Migration[7.0]
  def change
    remove_column :workflow_definition_processes, :start_considering, :boolean
  end
end
