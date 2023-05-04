class AddInstanceStepColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_instance_steps, :min_worktime, :integer
    add_column :workflow_instance_steps, :max_worktime, :integer
    add_column :workflow_instance_steps, :decision_question, :string
  end
end
