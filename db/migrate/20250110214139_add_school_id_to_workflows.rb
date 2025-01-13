class AddSchoolIdToWorkflows < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_instance_workflows, :school_id, :bigint
  end
end
