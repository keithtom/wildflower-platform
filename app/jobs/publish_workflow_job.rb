class PublishWorkflowJob < ApplicationJob
  queue_as :default

  def perform(workflow_definition_id)
    Workflow::Definition::Workflow::Publish.run(workflow_definition_id)
  end
end
