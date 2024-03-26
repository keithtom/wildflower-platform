class AddUniqueIndexToWorkflows < ActiveRecord::Migration[7.0]
  def change
    add_index :workflow_definition_workflows, [:name, :version], unique: true
  end
end
