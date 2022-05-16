class CreateAdviceEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :advice_events do |t|
      t.belongs_to :decision
      t.belongs_to :originator, polymorphic: true, index: false

      t.string :name
      t.string :description
      t.timestamps
    end
  end
end
