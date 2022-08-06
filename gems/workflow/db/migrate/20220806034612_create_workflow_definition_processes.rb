class CreateWorkflowDefinitionProcesses < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_definition_processes do |t|
      t.string :version
      t.string :name
      t.text :description

      # timing
      t.integer :weight

      t.timestamps
    end
  end
end
