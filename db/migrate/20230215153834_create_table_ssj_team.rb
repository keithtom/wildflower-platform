class CreateTableSsjTeam < ActiveRecord::Migration[7.0]
  def change
    create_table :ssj_teams do |t|
      t.string :external_identifier, null: false
      t.references :workflow, foreign_key: { to_table: :workflow_instance_workflows }
      t.timestamps
    end

    add_reference :people, :ssj_team, foreign_key: { to_table: :ssj_teams }
  end
end
