class AddWorkflowIdToSchool < ActiveRecord::Migration[7.0]
  def change
    add_reference :schools, :workflow, foreign_key: { to_table: :workflow_instance_workflows }, index: { unique: true }
  end
end