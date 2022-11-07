# initialize the workflow for this user

# from here we cna use api to update
# keep mapping data here to workflow
#

class SSJ::Initialize < BaseService
  def initialize(workflow_definition)
    # TODO: pass in user
    @workflow_definition = workflow_definition
  end

  def run
    wf_instance = @workflow_definition.instances.create!
    # TODO: associate to user somehow
    @workflow_definition.processes.each do |process_definition|
      process_instance = process_definition.instances.create!(workflow_instance_workflow_id: wf_instance.id) #TODO: assign to user
      process_definition.steps.each do |step_definition|
        step_definition.instances.create!(workflow_instance_process_id: process_instance.id)
      end
    end
  end
end
