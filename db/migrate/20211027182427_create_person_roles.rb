class CreatePersonRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :person_roles do |t|
      t.belongs_to :person
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
