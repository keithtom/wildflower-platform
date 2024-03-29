class CreateTableSSJTeam < ActiveRecord::Migration[7.0]
  def change
    create_table :ssj_teams do |t|
      t.string :external_identifier, null: false, index: { unique: true }
      t.references :workflow, foreign_key: { to_table: :workflow_instance_workflows }
      t.date :expected_start_date
      t.timestamps
    end

    add_reference :people, :ssj_team, foreign_key: { to_table: :ssj_teams }, index: { unique: true }
  end
end
