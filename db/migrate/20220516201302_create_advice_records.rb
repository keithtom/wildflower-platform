class CreateAdviceRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :advice_records do |t|
      t.belongs_to :decision
      t.belongs_to :stakeholder, index: false

      t.text :content
      t.string :status

      t.string :impede_your_role
      t.string :will_do_harm
      t.string :harm_hard_to_reverse

      t.timestamps
    end
  end
end
