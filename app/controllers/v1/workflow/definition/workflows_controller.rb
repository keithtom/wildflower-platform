class V1::Workflow::Definition::WorkflowsController < ApiController
  before_action :authenticate_admin!

  def index
    workflows = Workflow::Definition::Workflow.latest_versions
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflows)
  end

  def show
    workflow = Workflow::Definition::Workflow.find(params[:id])
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow)
  end

  def create
    workflow = Workflow::Definition::Workflow.create!(workflow_params)
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow)
  end

  def update
    workflow = Workflow::Definition::Workflow.find(params[:id])
    workflow.update!(workflow_params)
    # TODO run command that updates the instances
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow)
  end

  private

  def workflow_params
    params.require(:workflow).permit(:version, :name, :description)
  end
end
