class AddSchoolRelationshipExtId < ActiveRecord::Migration[7.0]
  def change
    add_column :school_relationships, :external_identifier, :string
    add_index :school_relationships, :external_identifier, unique: true
  end
end
