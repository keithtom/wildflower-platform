class CreateSsjWorkflowInstanceTable < ActiveRecord::Migration[7.0]
  def change
    create_table :ssj_workflow_instances do |t|
      t.belongs_to :workflow_instance_workflow
      t.belongs_to :person
      t.string :external_identifier, null: false, unique: true

      t.timestamps
    end
  end
end
