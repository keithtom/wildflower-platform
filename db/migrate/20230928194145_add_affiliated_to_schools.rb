class AddAffiliatedToSchools < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :affiliated, :boolean, default: true
  end
end
