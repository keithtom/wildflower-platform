class ProcessCaches < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_instance_processes, :dependency_cache, :integer, default: 0
  end
end
