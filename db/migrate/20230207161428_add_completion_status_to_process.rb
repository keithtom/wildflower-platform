class AddCompletionStatusToProcess < ActiveRecord::Migration[7.0]
  def up
    add_column :workflow_instance_processes, :completion_status, :integer, default: 0

    Workflow::Instance::Step.all.each do |step|
      step.save!
    end
  end

  def down
    remove_column :workflow_instance_processes, :completion_status
  end
end
