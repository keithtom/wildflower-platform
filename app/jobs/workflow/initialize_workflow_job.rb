class Workflow::InitializeWorkflowJob < ApplicationJob
  queue_as :default

  def perform(workflow_instance_id)
    Workflow::Initialize.run(workflow_instance_id)
  end
end
# 