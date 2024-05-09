class RemoveUniquenessIndexOnWorkflow < ActiveRecord::Migration[7.0]
  def change
    remove_index :workflow_definition_workflows, [:name, :version], unique: true
  end
end
