class Fixes < ActiveRecord::Migration[7.0]
  def change
    add_index :hubs, :name, unique: true
    add_column :schools, :domain, :string
    add_column :schools, :logo_url, :string
    add_column :schools, :hub_id, :bigint
    add_index :schools, :hub_id
    add_column :schools, :raw_address, :string
    add_column :schools, :opened_on, :date
    remove_column :schools, :tuition_assistance_type
    remove_column :schools, :ages_served
  end
end
