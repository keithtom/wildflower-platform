# frozen_string_literal: true

class CreateSchools < ActiveRecord::Migration[7.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.string :old_name

      t.string :website
      t.string :phone
      t.string :email

      t.string :governance_type
      t.string :tuition_assistance_type
      t.string :ages_served # should support many...
      t.string :calendar
      t.integer :max_enrollment

      t.string :status

      t.timestamps
    end
  end
end
