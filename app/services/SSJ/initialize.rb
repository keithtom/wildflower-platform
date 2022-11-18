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
      process_instance = process_definition.instances.create!(workflow: wf_instance) #TODO: assign to user
      process_definition.steps.each do |step_definition|
        step_definition.instances.create!(process_id: process_instance.id)
      end
    end

    @workflow_definition.dependencies.each do |dependency_definition|
      process_id = dependency_definition.workable.id
      prerequisite_process_id = dependency_definition.prerequisite_workable.id
      instance_workable = wf_instance.processes.where(definition_id: process_id).first
      instance_prerequisite_workable = wf_instance.processes.where(definition_id: prerequisite_process_id).first

      dependency_instance = dependency_definition.instances.create!(
        workflow: wf_instance,
        workable: instance_workable,
        prerequisite_workable: instance_prerequisite_workable
      )
    end
    wf_instance
  end
end
