class V1::Workflow::Definition::ProcessesController < ApiController
  before_action :authenticate_admin!
 
  def index
    processes = Workflow::Definition::Process.includes([:taggings, :categories]).all
    render json: V1::Workflow::Definition::ProcessSerializer.new(processes, serialization_options)
  end

  def show
    process = Workflow::Definition::Process.find(params[:id])
    render json: V1::Workflow::Definition::ProcessSerializer.new(process, serialization_options)
  end
 
  def create
    workflow = Workflow::Definition::Workflow.find(params[:workflow_id])
    if workflow
      process = Workflow::Definition::Process.create!(process_params)
      Workflow::Definition::SelectedProcess.create!(workflow_id: workflow.id, process_id: process.id)
      render json: V1::Workflow::Definition::ProcessSerializer.new(process, serialization_options)
    else
      render json: {
        status: 422,
        message: "workflow_id required"
      }, status: :unprocessable_entity
    end
  end

  def update
    process = Workflow::Definition::Process.find(params[:id])
    process.update!(process_params)
    # TODO run command that updates the instances
    render json: V1::Workflow::Definition::ProcessSerializer.new(process, serialization_options)
  end

  def destroy 
    process = Workflow::Definition::Process.find(params[:id])
    process.destroy!
    render json: { message: 'Process deleted successfully' }
  end

  private

  def process_params
    params.require(:process).permit(:version, :title, :description, :position, 
    steps_attributes: [:id, :title, :description, :position, :kind, :completion_type, 
    decision_options_attributes: [:description],
    documents_attributes: [:id, :title, :link]])
  end

  def serialization_options
    { include: ['steps'] }
  end
end
