# This is really a workflow service
class SSJ::Initialize < BaseService
  def initialize(workflow_definition)
    @workflow_definition = workflow_definition
  end

  def run
    @wf_instance = @workflow_definition.instances.create!

    create_process_and_step_instances

    create_dependency_instances

    update_process_dependencies

    @wf_instance
  end

  private

  def create_process_and_step_instances
    @workflow_definition.processes.each do |process_definition|
      process_instance = process_definition.instances.create!(workflow: @wf_instance)
      process_definition.steps.each do |step_definition|
        step_definition.instances.create!(process_id: process_instance.id)
      end
    end
  end

  def create_dependency_instances
    @workflow_definition.dependencies.each do |dependency_definition|
      # this code assumes all workables are processes
      process_id = dependency_definition.workable.id
      prerequisite_process_id = dependency_definition.prerequisite_workable.id
      
      instance_workable = @wf_instance.processes.where(definition_id: process_id).first
      instance_prerequisite_workable = @wf_instance.processes.where(definition_id: prerequisite_process_id).first

      dependency_definition.instances.create!(
        workflow: @wf_instance,
        workable: instance_workable,
        prerequisite_workable: instance_prerequisite_workable
      )
    end
  end

  def update_process_dependencies
    @wf_instance.processes.each do |process|
      if process.prerequisites.empty?
        process.dependencies_met!
      end
    end
  end
end
