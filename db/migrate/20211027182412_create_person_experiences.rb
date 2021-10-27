class CreatePersonExperiences < ActiveRecord::Migration[6.1]
  def change
    create_table :person_experiences do |t|
      t.belongs_to :person
      t.string :type

      t.string :name
      t.text :description

      t.date :start_date
      t.date :end_date

      t.belongs_to :school

      t.timestamps
    end
  end
end
