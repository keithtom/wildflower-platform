class AddAirtableIdToSchoolRelationships < ActiveRecord::Migration[7.0]
  def change
    add_column :school_relationships, :airtable_id, :string
    add_index :school_relationships, :airtable_id, :unique => true
  end
end
