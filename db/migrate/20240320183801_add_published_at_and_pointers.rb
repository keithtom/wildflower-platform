class AddPublishedAtAndPointers < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_workflows, :published_at, :datetime
    add_column :workflow_definition_workflows, :previous_version_id, :bigint

    add_column :workflow_definition_processes, :published_at, :datetime
    add_column :workflow_definition_processes, :previous_version_id, :bigint

    add_column :workflow_definition_selected_processes, :previous_version_id, :bigint
    add_column :workflow_definition_selected_processes, :state, :string
  end
end
