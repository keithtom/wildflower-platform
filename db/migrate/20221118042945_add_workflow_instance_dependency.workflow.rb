# This migration comes from workflow (originally 20221117231822)
class AddWorkflowInstanceDependency < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_instance_dependencies do |t|
      t.belongs_to :definition
      t.belongs_to :workflow

      t.belongs_to :workable, polymorphic: true
      t.belongs_to :prerequisite_workable, polymorphic: true

      t.timestamps
    end
  end
end
