class AdviceApi < ActiveRecord::Migration[7.0]
  def change
    add_column :advice_decisions, :external_identifier, :string, null: false
    add_index :advice_decisions, :external_identifier, unique: true

    add_column :advice_messages, :external_identifier, :string, null: false
    add_index :advice_messages, :external_identifier, unique: true

    add_column :advice_stakeholders, :external_identifier, :string, null: false
    add_index :advice_stakeholders, :external_identifier, unique: true

  end
end
