class V1::Workflow::Definition::ProcessesController < ApiController
  include WorkflowAttributes

  before_action :authenticate_admin!

  def index
    processes = Workflow::Definition::Process.includes([:taggings, :categories, {
                                                         steps: %i[decision_options documents]
                                                       }]).all
    render json: V1::Workflow::Definition::ProcessSerializer.new(processes)
  end

  def show
    process = Workflow::Definition::Process.find(params[:id])

    process_serialization_options = serialization_options
    process_serialization_options.merge!({ params: { workflow_id: params[:workflow_id] } }) if params[:workflow_id]

    render json: V1::Workflow::Definition::ProcessSerializer.new(process, process_serialization_options)
  end

  def create
    process = Workflow::Definition::Process.create!(process_params)
    render json: V1::Workflow::Definition::ProcessSerializer.new(process, serialization_options)
  end

  def update
    process = Workflow::Definition::Process.find(params[:id])

    if process.published? # if published, then changes will be instantaneous
      begin
        Workflow::Definition::Process::PropagateInstantaneousChange.run(process, process_params)
      rescue Exception => e
        log_error(e)
        return render json: { message: e.message }, status: :bad_request
      end
    else
      process.update!(process_params)
    end

    render json: V1::Workflow::Definition::ProcessSerializer.new(process, serialization_options)
  end

  def destroy
    process = Workflow::Definition::Process.find(params[:id])
    if process.instances.empty?
      process.destroy!
      render json: { message: 'Process deleted successfully' }
    else
      render json: { message: 'Cannot delete process because it has instances' }, status: :unprocessable_entity
    end
  end

  private

  def process_params
    params.require(:process).permit(process_attributes)
  end

  def serialization_options
    { include: %w[steps selected_processes prerequisites workable_dependencies] }
  end
end
