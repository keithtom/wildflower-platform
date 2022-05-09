class CreatePeopleRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :people_relationships do |t|
      t.belongs_to :person_id
      t.belongs_to :other_person_id

      t.string :kind

      t.timestamps
    end
  end
end
