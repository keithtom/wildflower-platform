workflow_definition = Workflow::Definition.find_by(title: 'Open School Checklist')

workflow_definition.instances.each do |workflow_instance|
  Workflow::InitializeWorkflowJob.perform_later(workflow_instance.id)
end
