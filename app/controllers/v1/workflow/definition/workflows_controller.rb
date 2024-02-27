class V1::Workflow::Definition::WorkflowsController < ApiController
  before_action :authenticate_admin!, only: [:create, :update]

  def create
    workflow = Workflow::Definition::Workflow.create(workflow_params)
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow)
  end

  def update
    workflow = Workflow::Definition::Workflow.find(params[:id])
    workflow.update(workflow_params)
    # TODO run command that updates the instances
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow)
  end

  private

  def workflow_params
    params.require(:workflow).permit(:version, :name, :description)
  end
end
