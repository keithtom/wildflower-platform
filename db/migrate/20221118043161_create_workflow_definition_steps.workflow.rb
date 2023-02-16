# This migration comes from workflow (originally 20220806034616)
class CreateWorkflowDefinitionSteps < ActiveRecord::Migration[7.0]
  def change
    # acts as an ordered list w/ ints?
    # for conditional or inserted steps?  increment by 100?
    create_table :workflow_definition_steps do |t|
      t.belongs_to :process # this means a step can only belong to 1 process.  HABTM would let multiple processes use the same step.  this means editing a single step would impact many processes.

      t.string :name
      t.text :description
      t.string :kind

      # timing
      t.integer :weight

      # doing
      t.string :url
      t.text :content

      t.timestamps
    end
  end
end
