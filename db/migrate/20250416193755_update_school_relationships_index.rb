class UpdateSchoolRelationshipsIndex < ActiveRecord::Migration[7.0]
  def change
    # Remove the existing index
    remove_index :school_relationships, name: "index_school_relationships_on_person_id_and_school_id", column: [:person_id, :school_id]
    
    # Add the new index with OR condition
    add_index :school_relationships, [:person_id, :school_id], 
              unique: true, 
              where: "deleted_at IS NULL AND end_date IS NULL",
              name: 'index_school_relationships_on_person_id_and_school_id'
  end
end
