# frozen_string_literal: true

class CreateModels < ActiveRecord::Migration[7.0]
  def change
    create_table :skills do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    create_table :person_skills do |t|
      t.belongs_to :person
      t.belongs_to :skill

      t.timestamps
    end

    create_table :roles do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    create_table :person_roles do |t|
      t.belongs_to :person
      t.belongs_to :role
      
      t.timestamps
    end

    create_table :addresses do |t|
      t.references :addressable, polymorphic: true

      t.string :line1
      t.string :line2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country

      t.timestamps
    end

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
