class AddProcessCounterToInstanceStepsTable < ActiveRecord::Migration[7.0]
  def up
    add_column :workflow_instance_processes, :steps_count, :bigint
    add_column :workflow_instance_processes, :completed_steps_count, :bigint

    Workflow::Instance::Process.each do |process|
      process.steps_count = process.steps.count
      process.completed_steps_count = proess.steps.where(completed: true)
      process.save!
    end
  end

  def down
    remove_column :workflow_instance_processes, :steps_count
    remove_column :workflow_instance_processes, :completed_steps_count
  end
end
