class V1::Workflow::WorkflowsController < ApiController
  def show
    # TODO: identify current user, check if workflow id is accessible to user
    # figure out which workflows they have with that ID

    @workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:id])
    render json: V1::Workflow::WorkflowSerializer.new(@workflow, include: ['processes'])
  end

  def resources
    @workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    process_ids = @workflow.processes.pluck(:id)
    instance_step_ids = Workflow::Instance::Step.where(process_id: process_ids).pluck(:id)
    definition_step_ids = Workflow::Instance::Step.where(process_id: process_ids).pluck(:definition_id)

    ## document could either be from step or definition
    documents = Document.where(documentable_id: instance_step_ids, documentable_type: Workflow::Instance::Step.to_s)
    documents += Document.where(documentable_id: definition_step_ids, documentable_type: Workflow::Definition::Step.to_s)

    render json: V1::DocumentSerializer.new(documents)
  end
end
