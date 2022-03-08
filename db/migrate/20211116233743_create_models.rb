# frozen_string_literal: true

class CreateModels < ActiveRecord::Migration[7.0]
  def change
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
end
