class AddDeletedAtToParanoiac < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :deleted_at, :datetime
    add_index :addresses, :deleted_at

    add_column :charters, :deleted_at, :datetime
    add_index :charters, :deleted_at

    add_column :hubs, :deleted_at, :datetime
    add_index :hubs, :deleted_at

    add_column :people, :deleted_at, :datetime
    add_index :people, :deleted_at

    add_column :pods, :deleted_at, :datetime
    add_index :pods, :deleted_at

    add_column :school_relationships, :deleted_at, :datetime
    add_index :school_relationships, :deleted_at

    add_column :schools, :deleted_at, :datetime
    add_index :schools, :deleted_at

    add_column :ssj_team_members, :deleted_at, :datetime
    add_index :ssj_team_members, :deleted_at

    add_column :ssj_teams, :deleted_at, :datetime
    add_index :ssj_teams, :deleted_at

    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at

    add_column :workflow_definition_dependencies, :deleted_at, :datetime
    add_index :workflow_definition_dependencies, :deleted_at

    add_column :workflow_definition_processes, :deleted_at, :datetime
    add_index :workflow_definition_processes, :deleted_at

    add_column :workflow_definition_selected_processes, :deleted_at, :datetime
    add_index :workflow_definition_selected_processes, :deleted_at

    add_column :workflow_definition_steps, :deleted_at, :datetime
    add_index :workflow_definition_steps, :deleted_at

    add_column :workflow_definition_workflows, :deleted_at, :datetime
    add_index :workflow_definition_workflows, :deleted_at

    add_column :workflow_instance_dependencies, :deleted_at, :datetime
    add_index :workflow_instance_dependencies, :deleted_at

    add_column :workflow_instance_processes, :deleted_at, :datetime
    add_index :workflow_instance_processes, :deleted_at

    add_column :workflow_instance_steps, :deleted_at, :datetime
    add_index :workflow_instance_steps, :deleted_at

    add_column :workflow_instance_workflows, :deleted_at, :datetime
    add_index :workflow_instance_workflows, :deleted_at
  end
end
