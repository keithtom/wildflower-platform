class V1::Workflow::WorkflowsController < ApiController
  def show
    # TODO: identify current user, check if workflow id is accessible to user
    # figure out which workflows they have with that ID

    @workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:id])
    render json: V1::Workflow::WorkflowSerializer.new(@workflow)
  end

  def resources
    process_ids = workflow.processes.pluck(:id)
    instance_step_ids = Workflow::Instance::Step.where(process_id: process_ids).pluck(:id)
    definition_step_ids = Workflow::Instance::Step.where(process_id: process_ids).pluck(:definition_id)

    ## document could either be from instance or definition
    documents = Document.where(documentable_id: instance_step_ids, documentable_type: Workflow::Instance::Step.to_s).includes(documentable: [process: [:categories]])
    documents += Document.where(documentable_id: definition_step_ids, documentable_type: Workflow::Definition::Step.to_s).includes(documentable: [process: [:categories]])

    render json: V1::Workflow::ResourceSerializer.new(documents)
  end

  # assume that workflow_id is passed in
  # params would include assignee_id
  def assigned_steps
    # find all the incomplete assignments/steps for this partner and this specific workflow.
    workflow = Workflow::Instance::Workflow.find_by(external_identifier: params[:workflow_id])
    eager_load_associations = [:assignee, step: [:documents, process: [:definition], assignments: [:step, :assignee], definition: [:decision_options, :documents]]]
    assignments = Workflow::Instance::StepAssignment.for_workflow(workflow.id).incomplete.includes(*eager_load_associations)
    if params[:assignee_id]
      assignments = assignments.where(assignee_id: params[:assignee_id])
    end
    if params[:current_user]
      assignments = assignments.where(assignee_id: current_user.person_id)
    end

    steps = assignments.map { |assignment| assignment.step }

    # before we could group steps by 1 assignee, now we have multiple assignees per step so grouping that way doens't work
    # we can have assignment serializer handle serialization of steps, because it'd save us dual step serialization.
    serialization_options = {}
    if current_user.person_id == params[:assignee_id] || params[:current_user]
      serialization_options[:params] = { current_user: current_user }
    end
    serialization_options[:include] = ['process', 'documents', 'assignments', 'assignments.assignee', 'decision_options']
    serialization_options[:fields] = {
      process: [:title],
      person: [:firstName, :lastName, :profileImageAttachment, :imageUrl],
    }

    render json: V1::Workflow::StepSerializer.new(steps, serialization_options)
  end
end
