class AddProcessStartConsidering < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_processes, :start_considering, :boolean, default: false
  end
end
