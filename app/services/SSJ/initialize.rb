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

      # puts "definition", process_definition.category_list, process_definition.phase_list
      attributes = process_definition.attributes.with_indifferent_access.slice(:title, :description, :position)
      # puts "attributes", attributes.as_json
      attributes.merge!(workflow: @wf_instance)
      process_instance = process_definition.instances.create!(attributes)
      process_instance.category_list = process_definition.category_list
      process_instance.phase_list = process_definition.phase_list
      process_instance.save!
      # puts "instance", process_instance.as_json

      process_definition.steps.each do |step_definition|
        # copy over documents? that seems a bit much.
        attributes = step_definition.attributes.with_indifferent_access.slice(:title, :description, :kind, :completion_type, :min_worktime, :max_worktime, :decision_question, :position)
        attributes.merge!(process_id: process_instance.id)
        step_definition.instances.create!(attributes)
      end
    end
  end

  def create_dependency_instances
    @workflow_definition.dependencies.includes(:workable, :prerequisite_workable).each do |dependency_definition|
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
        process.prerequisites_met!
      end
    end
  end
end
