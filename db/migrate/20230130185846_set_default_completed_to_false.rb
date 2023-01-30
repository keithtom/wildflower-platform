class SetDefaultCompletedToFalse < ActiveRecord::Migration[7.0]
  def up
    change_column :workflow_instance_steps, :completed, :bool, default: false

    Workflow::Instance::Step.all.each do |step|
      if step.completed.nil?
        step.completed = false
        step.save
      end
    end
  end

  def down
    Workflow::Instance::Step.all.each do |step|
      if !step.completed
        step.completed = nil
        step.save
      end
    end

  end
end

