class Fixes2 < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :airtable_partner_id, :string
    
  end
end
