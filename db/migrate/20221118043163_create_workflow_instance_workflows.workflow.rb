# This migration comes from workflow (originally 20221005150246)
class CreateWorkflowInstanceWorkflows < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_instance_workflows do |t|
      t.belongs_to :definition

      t.timestamps
    end
  end
end
