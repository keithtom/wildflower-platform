class CreatePersonSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :person_skills do |t|
      t.belongs_to :person
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
