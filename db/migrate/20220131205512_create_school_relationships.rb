class CreateSchoolRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :school_relationships do |t|
      t.string :kind # entrepeneur, board member, founder, employee? overlaps w/ experience a bit...
      t.timestamps
    end
  end
end
