class Fixes2 < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :airtable_partner_id, :string
    add_column :people, :linkedin_url, :string

    add_column :schools, :facility_type, :string
  end
end
