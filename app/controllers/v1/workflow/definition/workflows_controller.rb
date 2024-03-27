class V1::Workflow::Definition::WorkflowsController < ApiController
  before_action :authenticate_admin!

  def index
    workflows = Workflow::Definition::Workflow.latest_versions
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflows, serializer_options)
  end

  def show
    workflow = Workflow::Definition::Workflow.find(params[:id])
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow, serializer_options.merge!({params: {workflow_id: params[:id]}}))
  end

  def create
    workflow = Workflow::Definition::Workflow.create!(workflow_params)
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow, serializer_options.merge!({params: {workflow_id: params[:id]}}))
  end

  def update
    workflow = Workflow::Definition::Workflow.find(params[:id])
    workflow.update!(workflow_params)
    # TODO run command that updates the instances
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow, serializer_options.merge!({params: {workflow_id: params[:id]}}))
  end

  def add_process
    workflow = Workflow::Definition::Workflow.find(params[:workflow_id])
    if workflow&.published?
      render json: { error: "Cannot add processes to a published workflow. Please create a new version to continue." }, status: :unprocessable_entity
    else
      process = Workflow::Definition::Process.create!(process_params)
      Workflow::Definition::SelectedProcess.create(workflow_id: workflow.id, process_id: process.id)

      render json: V1::Workflow::Definition::ProcessSerializer.new(process, { include: ['steps', 'selected_processes', 'prerequisites'] })
    end
  end

  private

  def workflow_params
    params.require(:workflow).permit(:version, :name, :description)
  end

  def process_params
    params.require(:process).permit(:version, :title, :description, :phase_list, :categories_list,
    steps_attributes: [:id, :title, :description, :position, :kind, :completion_type, :min_worktime, :max_worktime,
    decision_options_attributes: [:description],
    documents_attributes: [:id, :title, :link]],
    selected_processes_attributes: [:id, :workflow_id, :position],
    workable_dependencies_attributes: [:id, :workflow_id, :prerequisite_workable_type, :prerequisite_workable_id])
  end

  def serializer_options
    { include: ['processes', 'processes.selected_processes'] }
  end
end
