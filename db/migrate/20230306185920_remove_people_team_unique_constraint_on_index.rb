class RemovePeopleTeamUniqueConstraintOnIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :people, :ssj_team_id # removing the unique constraint b/c more than one person on a team
    add_index :people, :ssj_team_id
  end
end
