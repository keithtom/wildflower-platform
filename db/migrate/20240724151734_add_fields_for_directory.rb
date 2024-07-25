class AddFieldsForDirectory < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :montessori_certified_year, :string
  end
end
