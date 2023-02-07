class V1::Ssj::DashboardController < ApiController
  def progress
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    processes = workflow.processes.eager_load(:prerequisites, :steps, :categories, definition: [:phase, :categories])
    render json: V1::Ssj::ProcessProgressSerializer.new(processes)
  end
end


