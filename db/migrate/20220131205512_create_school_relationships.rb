class CreateSchoolRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :school_relationships do |t|
      t.string :kind # entrepeneur, board member, founder, employee? overlaps w/ experience a bit...

      t.belongs_to :school
      t.belongs_to :person

      t.string :name
      t.text :description

      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
