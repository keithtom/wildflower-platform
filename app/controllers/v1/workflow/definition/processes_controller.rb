class V1::Workflow::Definition::ProcessesController < ApiController
  before_action :authenticate_admin!
 
  def index
    processes = Workflow::Definition::Process.includes([:taggings, :categories]).all
    render json: V1::Workflow::Definition::ProcessSerializer.new(processes)
  end

  def show
    process = Workflow::Definition::Process.find(params[:id])
    render json: V1::Workflow::Definition::ProcessSerializer.new(process)
  end
 
  def create
    process = Workflow::Definition::Process.create!(process_params)
    render json: V1::Workflow::Definition::ProcessSerializer.new(process)
  end

  def update
    process = Workflow::Definition::Process.find(params[:id])
    process.update!(process_params)
    # TODO run command that updates the instances
    render json: V1::Workflow::Definition::ProcessSerializer.new(process)
  end

  def destroy
    process = Workflow::Definition::Process.find(params[:id])
    process.destroy!
    render json: { message: 'Process deleted successfully' }
  end


  private

  def process_params
    params.require(:process).permit(:version, :title, :description, :position)
  end
end
