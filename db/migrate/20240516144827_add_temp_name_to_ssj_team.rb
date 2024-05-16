class AddTempNameToSSJTeam < ActiveRecord::Migration[7.0]
  def change
    add_column :ssj_teams, :temp_name, :string
  end
end
