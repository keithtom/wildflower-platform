class AddPersonImageUrl < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :image_url, :string
    add_column :advice_stakeholders, :external_image_url, :string
  end
end
