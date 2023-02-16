# This migration comes from workflow (originally 20221122200449)
class AddProcessCounterToInstanceStepsTable < ActiveRecord::Migration[7.0]
  def up
    add_column :workflow_instance_processes, :steps_count, :bigint
    add_column :workflow_instance_processes, :completed_steps_count, :bigint

    Workflow::Instance::Process.find_each do |process|
      Workflow::Instance::Process.reset_counters(process.id, :steps)
      process.completed_steps_count = process.steps.where(completed: true).count
      process.save!
    end
  end

  def down
    remove_column :workflow_instance_processes, :steps_count
    remove_column :workflow_instance_processes, :completed_steps_count
  end
end
