class CreatePods < ActiveRecord::Migration[7.0]
  def change
    create_table :pods do |t|
      t.string :name
      t.belongs_to :hub
      t.belongs_to :primary_contact
      t.string :external_identifier, null: false

      t.timestamps
    end
    add_index :pods, :external_identifier, unique: true

    add_column :schools, :pod_id, :bigint
    add_index :schools, :pod_id

    add_column :schools, :short_name, :string
    add_column :schools, :airtable_id, :string
    add_index :schools, :airtable_id, :unique => true

    add_column :schools, :facebook, :string
    add_column :schools, :instagram, :string
    add_column :schools, :timezone, :string
  end
end
