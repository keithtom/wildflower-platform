class CreateAdviceDecisions < ActiveRecord::Migration[7.0]
  def change
    create_table :advice_decisions do |t|
      t.belongs_to :creator

      t.string :state
      t.string :title
      t.text :context
      t.text :proposal
      t.text :links, array: true, :default => []

      t.datetime :decide_by
      t.datetime :advice_by

      t.string :role

      t.text :final_summary

      t.timestamps
    end
  end
end
