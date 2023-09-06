class AddIsOnboardedToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :is_onboarded, :boolean, default: false
  end
end
