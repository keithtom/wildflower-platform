class PeopleFixes < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :middle_name, :string

    add_column :people, :personal_email, :string
    add_column :people, :raw_address, :string

    add_column :people, :airtable_id, :string
    add_index :people, :airtable_id, :unique => true

    add_column :people, :hub_id, :bigint
    add_column :people, :pod_id, :bigint
    add_index :people, :hub_id
    add_index :people, :pod_id

    add_column :people, :about, :text

    add_column :people, :tc_user_id, :string
    add_column :people, :prosperworks_id, :string

    add_column :people, :willing_to_relocate, :boolean

    add_column :people, :primary_language, :string
    add_column :people, :race_ethnicity_other, :string
    add_column :people, :household_income, :string
    add_column :people, :income_background, :string
    add_column :people, :gender, :string
    add_column :people, :gender_other, :string
    add_column :people, :lgbtqia, :boolean
    add_column :people, :pronouns, :string
    add_column :people, :pronouns_other, :string
  end
end
