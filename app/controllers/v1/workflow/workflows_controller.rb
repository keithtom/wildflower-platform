class V1::Workflow::WorkflowsController < ApiController
  before_action :authenticate_admin!, only: %i[update create]

  def create
    workflow = Workflow::Create.call(
      definition_id: workflow_params[:definition_id],
      school_id: workflow_params[:school_id]
    )
    render json: V1::Workflow::WorkflowSerializer.new(workflow)
  rescue Workflow::ServiceError => e
    render json: { error: e.message }, status: e.status
  end

  def show
    # TODO: identify current user, check if workflow id is accessible to user
    # figure out which workflows they have with that ID

    @workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:id])
    render json: V1::Workflow::WorkflowSerializer.new(@workflow)
  end

  def update
    @workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:id])
    @workflow.update!(workflow_params)
    render json: V1::Workflow::WorkflowSerializer.new(@workflow)
  end

  def resources
    process_ids = workflow.processes.pluck(:id)
    instance_step_ids = Workflow::Instance::Step.where(process_id: process_ids).pluck(:id)
    definition_step_ids = Workflow::Instance::Step.where(process_id: process_ids).pluck(:definition_id)

    ## document could either be from instance or definition
    includes = { documentable: [process: %i[categories]] }
    includes = { documentable: [process: %i[categories phase]] } if params[:phase].present?
    documents = Document.where(documentable_id: instance_step_ids,
                               documentable_type: Workflow::Instance::Step.to_s).includes(includes)
    documents += Document.where(documentable_id: definition_step_ids,
                                documentable_type: Workflow::Definition::Step.to_s).includes(includes)

    serializer = V1::Workflow::ResourceSerializer
    serializer = V1::ResourcesByCategorySerializer if params[:phase].present?
    render json: serializer.new(documents)
  end

  # assume that workflow_id is passed in
  # params would include assignee_id
  def assigned_steps
    # find all the incomplete assignments/steps for this partner and this specific workflow.
    workflow = Workflow::Instance::Workflow.find_by(external_identifier: params[:workflow_id])
    eager_load_associations = [:assignee, {
      step: [:documents, { process: [:definition], assignments: %i[step assignee], definition: %i[decision_options documents] }]
    }]
    assignments = Workflow::Instance::StepAssignment.for_workflow(workflow.id).incomplete.includes(*eager_load_associations)
    assignments = assignments.where(assignee_id: params[:assignee_id]) if params[:assignee_id]
    assignments = assignments.where(assignee_id: current_user.person_id) if params[:current_user]

    steps = assignments.map { |assignment| assignment.step }

    # before we could group steps by 1 assignee, now we have multiple assignees per step so grouping that way doens't work
    # we can have assignment serializer handle serialization of steps, because it'd save us dual step serialization.
    serialization_options = {}
    serialization_options[:params] = { current_user: }
    serialization_options[:include] =
      ['process', 'documents', 'assignments', 'assignments.assignee', 'decision_options']
    serialization_options[:fields] = {
      process: %i[title titleEs],
      person: %i[firstName lastName profileImageAttachment imageUrl]
    }

    render json: V1::Workflow::StepSerializer.new(steps, serialization_options)
  end

  private

  def workflow_params
    params.require(:workflow).permit(:visible, :definition_id, :school_id)
  end
end
