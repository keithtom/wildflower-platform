class AddSteopCompletionType < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_steps, :completion_type, :string
    add_column :workflow_instance_steps, :completion_type, :string
  end
end
