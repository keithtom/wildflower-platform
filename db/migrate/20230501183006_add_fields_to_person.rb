class AddFieldsToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :primary_language_other, :string
    add_column :people, :montessori_certified, :string
  end
end
