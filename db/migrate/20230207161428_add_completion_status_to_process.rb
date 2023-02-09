class AddCompletionStatusToProcess < ActiveRecord::Migration[7.0]
  def up
    Workflow::Instance::Process.all.each do |process|
      if process.completed_steps_count.nil?
        process.completed_steps_count = 0
        process.save!
      end
    end

    change_column :workflow_instance_processes, :completed_steps_count, :integer,  null: false, default: 0
    add_column :workflow_instance_processes, :completion_status, :integer, default: 0

    Workflow::Instance::Step.all.each do |step|
      step.save!
    end
  end

  def down
    remove_column :workflow_instance_processes, :completion_status
  end
end
