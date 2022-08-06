class CreateWorkflowDefinitionSelectedProcesses < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_definition_selected_processes do |t|
      t.belongs_to :workflow
      t.belongs_to :process

      t.timestamps
    end
  end
end
