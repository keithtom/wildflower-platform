# This is really a workflow service
class SSJ::Initialize < BaseService
  def initialize(wf_instance_id)
    @wf_instance = Workflow::Instance::Workflow.find(wf_instance_id)
    unless @wf_instance.processes.empty?
      raise "workflow instance #{@wf_instance.external_identifier} has already been instantiated with processes"
    end
    @workflow_definition = @wf_instance.definition
  end

  def run
    ActiveRecord::Base.transaction do
      create_process_and_step_instances
      create_dependency_instances
      update_process_dependencies
    end
  @wf_instance
  end

  private

  def create_process_and_step_instances
    @workflow_definition.processes.includes(:taggings, :steps).each do |process_definition|
      Workflow::Instance::Process::Create.run(process_definition, @wf_instance)
    end
  end

  def create_dependency_instances
    @workflow_definition.dependencies.includes(:workable, :prerequisite_workable).each do |dependency_definition|
      process_id = dependency_definition.workable.id
      instance_workable = @wf_instance.processes.where(definition_id: process_id).first

      Workflow::Instance::Dependency::Create.run(dependency_definition, @wf_instance, instance_workable)
    end
  end

  def update_process_dependencies
    @wf_instance.processes.each do |process|
      if process.prerequisites.empty?
        process.prerequisites_met!
      end
    end
  end
end
