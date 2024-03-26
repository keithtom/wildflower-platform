class V1::Workflow::Definition::WorkflowsController < ApiController
  before_action :authenticate_admin!

  def index
    workflows = Workflow::Definition::Workflow.all
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflows, serializer_options)
  end

  def show
    workflow = Workflow::Definition::Workflow.find(params[:id])
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow, serializer_options)
  end

  def create
    workflow = Workflow::Definition::Workflow.create!(workflow_params)
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow, serializer_options)
  end

  def update
    workflow = Workflow::Definition::Workflow.find(params[:id])
    workflow.update!(workflow_params)
    # TODO run command that updates the instances
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow, serializer_options)
  end

  private

  def workflow_params
    params.require(:workflow).permit(:version, :name, :description)
  end

  def serializer_options
    { include: ['processes'] }
  end
end
