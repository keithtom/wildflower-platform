class V1::Workflow::Definition::ProcessesController < ApiController
  before_action :authenticate_admin!
 
  def index
    processes = Workflow::Definition::Process.includes([:taggings, :categories, steps: [:decision_options, :documents]]).all
    render json: V1::Workflow::Definition::ProcessSerializer.new(processes)
  end

  def show
    process = Workflow::Definition::Process.find(params[:id])
    render json: V1::Workflow::Definition::ProcessSerializer.new(process, serialization_options)
  end
 
  def create
    process = Workflow::Definition::Process.create!(process_params)
    render json: V1::Workflow::Definition::ProcessSerializer.new(process, serialization_options)
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
    params.require(:process).permit(:version, :title, :description, :phase_list, :categories_list,
    steps_attributes: [:id, :title, :description, :position, :kind, :completion_type, :min_worktime, :max_worktime,
    decision_options_attributes: [:description],
    documents_attributes: [:id, :title, :link]],
    selected_processes_attributes: [:id, :workflow_id, :position],
    workable_dependencies_attributes: [:id, :workflow_id, :prerequisite_workable_type, :prerequisite_workable_id])
  end

  def serialization_options
    { include: ['steps', 'selected_processes', 'prerequisites'] }
  end
end
