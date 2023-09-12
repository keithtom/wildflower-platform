class AddChartersTable < ActiveRecord::Migration[7.0]
  def change
    create_table :charters do |t|
      t.string :name
      t.string :external_identifier, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
