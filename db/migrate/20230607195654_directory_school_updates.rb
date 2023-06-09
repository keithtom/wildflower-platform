class DirectorySchoolUpdates < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :about, :text
    add_column :schools, :about_es, :text
    add_column :schools, :hero_image2_url, :string
    add_column :schools, :charter_id, :bigint
    add_column :schools, :charter_string, :string
    add_column :schools, :closed_on, :date
    add_column :schools, :affiliation_date, :date
    add_column :schools, :num_classrooms, :integer

    add_column :people, :preferred_name, :string
    remove_column :schools, :old_name, :string

    add_index :schools, :charter_id
  end
end
