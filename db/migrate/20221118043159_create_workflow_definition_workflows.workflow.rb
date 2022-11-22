# This migration comes from workflow (originally 20220806034546)
class CreateWorkflowDefinitionWorkflows < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_definition_workflows do |t|
      # t.belongs_to :account
      t.string :version
      t.string :name
      t.text :description

      # author?
      t.timestamps
    end
  end
end
