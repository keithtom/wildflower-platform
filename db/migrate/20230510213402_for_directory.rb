class ForDirectory < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :affiliated_at, :datetime
  end
end
