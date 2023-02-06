class V1::Workflow::SsjController < ApiController
  def progress
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    processes = workflow.processes.eager_load(:prerequisites, definition: [:phase, :categories])
    render json: V1::Workflow::ProcessProgressSerializer.new(processes)
  end
end


