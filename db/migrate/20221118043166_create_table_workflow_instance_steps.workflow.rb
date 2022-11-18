# This migration comes from workflow (originally 20221012200632)
class CreateTableWorkflowInstanceSteps < ActiveRecord::Migration[7.0]
  def change
    rename_column(:workflow_definition_steps, :name, :title)
    rename_column(:workflow_definition_steps, :kind, :type)
    rename_column(:workflow_definition_steps, :url, :resource_url)
    remove_column(:workflow_definition_steps, :content)
    add_column(:workflow_definition_steps, :resource_title, :string)

    create_table :workflow_instance_steps do |t|
      t.belongs_to :process
      t.belongs_to :definition
      t.string :title
      t.string :type
      t.boolean :completed
      t.string :resource_url
      t.string :resource_title
      # weight

      t.timestamps
    end
  end
end
