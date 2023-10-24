class AddPlatformAirtableIdToPersonSchoolSchool < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :platform_airtable_id, :string
    add_column :people, :airtable_sync_at, :datetime
    add_column :schools, :platform_airtable_id, :string
    add_column :schools, :airtable_sync_at, :datetime
    add_column :school_relationships, :platform_airtable_id, :string
    add_column :school_relationships, :airtable_sync_at, :datetime
  end
end
