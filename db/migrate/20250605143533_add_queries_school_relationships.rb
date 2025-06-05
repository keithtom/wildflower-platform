class AddQueriesSchoolRelationships < ActiveRecord::Migration[7.0]
  def change
    # Add index for kind column (used in .active and .partners scopes)
    add_index :school_relationships, :kind, 
              name: 'index_school_relationships_on_kind'
    
    # Add index for end_date column (used in .active scope)
    add_index :school_relationships, :end_date, 
              name: 'index_school_relationships_on_end_date'
    
    # Add composite index for the most common query pattern:
    # WHERE school_id = ? AND kind = ? AND deleted_at IS NULL AND end_date IS NULL
    add_index :school_relationships, [:school_id, :kind, :deleted_at, :end_date], 
              name: 'index_school_relationships_on_school_kind_deleted_end',
              where: "deleted_at IS NULL"
    
    # Add composite index for active relationships by school
    # This optimizes: WHERE school_id = ? AND deleted_at IS NULL AND end_date IS NULL
    add_index :school_relationships, [:school_id, :deleted_at, :end_date], 
              name: 'index_school_relationships_on_school_active',
              where: "deleted_at IS NULL AND end_date IS NULL"
  end
end
