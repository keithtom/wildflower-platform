# This migration comes from workflow (originally 20221011211841)
class CreateTableWorkflowInstanceProcess < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_instance_processes do |t|
      t.belongs_to :definition
      t.belongs_to :workflow
      t.string :title
      t.text :description
      t.integer :weight # not sure if this should be effort
      t.integer :effort
      t.timestamp :started_at
      t.timestamp :completed_at
      t.references :assignee, foreign_key: {to_table: :people}

      t.timestamps
    end
  end
end
