class ChangeTypeFromStringToInteger < ActiveRecord::Migration[7.0]
  def change
    rename_column :workflow_definition_workflows, :version, :version_string
    add_column :workflow_definition_workflows, :version, :integer
  end
end
