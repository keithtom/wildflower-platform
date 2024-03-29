class AddPeopleToSSJTeam < ActiveRecord::Migration[7.0]
  def change
    add_reference :ssj_teams, :ops_guide, foreign_key: { to_table: :people }
    add_reference :ssj_teams, :regional_growth_lead, foreign_key: { to_table: :people }

    remove_reference :people, :ssj_team

    create_table :ssj_team_members do |t|
      t.references :person
      t.references :ssj_team, foreign_key: { to_table: :ssj_teams }
      t.string :role
      t.string :status
    end
  end
end
