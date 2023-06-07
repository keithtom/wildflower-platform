class NetworkUpdates < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :show_ssj, :boolean, default: false
    add_column :schools, :hero_image_url, :string
  end
end
