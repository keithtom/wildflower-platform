class CreateWorkflowDefinitionProcesses < ActiveRecord::Migration[7.0]
  def change
    # add account, and users belong to account.
    # API endpoints list all workflows and processes for account.
    create_table :workflow_definition_processes do |t|
      # t.belongs_to :account
      t.string :version
      t.string :name
      t.text :description

      # timing
      t.integer :weight

      t.timestamps
    end
  end
end
