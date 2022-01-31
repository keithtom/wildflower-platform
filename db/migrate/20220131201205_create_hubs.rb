class CreateHubs < ActiveRecord::Migration[7.0]
  def change
    create_table :hubs do |t|
      t.string :name
      t.belongs_to :entrepreneur

      t.string :external_identifier, null: false

      t.timestamps
    end
    add_index :hubs, :external_identifier, unique: true
  end
end
