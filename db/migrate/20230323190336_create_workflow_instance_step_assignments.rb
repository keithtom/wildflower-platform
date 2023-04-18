class CreateWorkflowInstanceStepAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_instance_step_assignments do |t|
      t.references :step, null: false, foreign_key: { to_table: :workflow_instance_steps }
      t.references :assignee, null: false

      t.datetime :completed_at
      t.timestamps
    end
  end
end
