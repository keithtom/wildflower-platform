class DirectoryUpdates < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :active, :boolean, default: true
    add_column :people, :start_date, :date
    add_column :people, :end_date, :date
  end
end
