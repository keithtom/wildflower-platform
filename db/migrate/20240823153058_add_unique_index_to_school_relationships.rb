class AddUniqueIndexToSchoolRelationships < ActiveRecord::Migration[7.0]
  def change
    # duplicates = SchoolRelationship
    #   .select('person_id, school_id, COUNT(*) as count')
    #   .group(:person_id, :school_id)
    #   .having('COUNT(*) > 1')
    # duplicates.each do |duplicate|
    #   SchoolRelationship
    #     .where(person_id: duplicate.person_id, school_id: duplicate.school_id)
    #     .order(:created_at) # or any other criteria to decide which record to keep
    #     .offset(1) # keep one record, remove the rest
    #     .destroy_all
    # end
    add_index :school_relationships, [:person_id, :school_id], unique: true, where: 'deleted_at IS NULL', name: 'index_school_relationships_on_person_id_and_school_id'
  end
end
