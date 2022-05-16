class CreateAdviceMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :advice_messages do |t|
      t.belongs_to :decision
      t.belongs_to :sender, polymorphic: true, index: false

      t.text :content

      t.timestamps
    end
  end
end
