class UniqueTeamMembers < ActiveRecord::Migration[7.0]
  def change
    # people can be on many teams
    # but not be on a single team twice in the same role.
    add_index :ssj_team_members, [:ssj_team_id, :person_id, :role], unique: true
  end
end
