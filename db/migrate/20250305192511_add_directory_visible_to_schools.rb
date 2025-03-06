class AddDirectoryVisibleToSchools < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :directory_visible, :boolean, default: false, null: false
  end
end
