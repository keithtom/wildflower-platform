class AddStepDescription < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_instance_steps, :description, :text
  end
end
