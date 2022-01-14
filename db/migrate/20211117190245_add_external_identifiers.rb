# frozen_string_literal: true

class AddExternalIdentifiers < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :external_identifier, :string, null: false
    add_index :people, :external_identifier, unique: true

    add_column :schools, :external_identifier, :string, null: false
    add_index :schools, :external_identifier, unique: true

    add_column :users, :external_identifier, :string, null: false
    add_index :users, :external_identifier, unique: true

    add_column :skills, :external_identifier, :string, null: false
    add_index :skills, :external_identifier, unique: true

    add_column :roles, :external_identifier, :string, null: false
    add_index :roles, :external_identifier, unique: true

    add_column :addresses, :external_identifier, :string, null: false
    add_index :addresses, :external_identifier, unique: true

    add_column :person_experiences, :external_identifier, :string, null: false
    add_index :person_experiences, :external_identifier, unique: true
  end
end
