# This migration comes from workflow (originally 20220806034716)
class CreateWorkflowDefinitionDependencies < ActiveRecord::Migration[7.0]
  def change
    # Dependencies are scope to a given workflow.
    # can define for a process/step a prequisite process/step
    # am i asking can I be started?
    # or am I asking, what is next?
    # what is next is whatever can be started.
    create_table :workflow_definition_dependencies do |t|
      t.belongs_to :workflow

      t.belongs_to :workable, polymorphic: true
      t.belongs_to :prequisite_workable, polymorphic: true

      t.timestamps
    end
  end
end
