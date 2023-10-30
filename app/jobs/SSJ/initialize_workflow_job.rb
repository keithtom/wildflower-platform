class SSJ::InitializeWorkflowJob < ApplicationJob
  queue_as :default

  def perform(workflow_instance_id)
    SSJ::Initialize.run(workflow_instance_id)
  end
end
# 