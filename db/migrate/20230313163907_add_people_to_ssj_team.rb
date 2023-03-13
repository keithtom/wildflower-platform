class AddPeopleToSsjTeam < ActiveRecord::Migration[7.0]
  def change
    add_reference :ssj_teams, :ops_guide, foreign_key: { to_table: :people }
    add_reference :ssj_teams, :regional_growth_guide, foreign_key: { to_table: :people }
  end
end
