class CreateTableWorkflowDecisionOption < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_decision_options do |t|
      t.belongs_to :decision
      t.string :description
      t.string :external_identifier, null: false, index: { unique: true }

      t.timestamps
    end

    add_reference :workflow_instance_steps, :selected_option
  end
end
