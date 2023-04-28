class StepDecisionQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_steps, :decision_question, :string
  end
end
