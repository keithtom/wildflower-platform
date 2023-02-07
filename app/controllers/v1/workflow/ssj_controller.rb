class V1::Workflow::SsjController < ApiController
  def progress
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    processes = workflow.processes.eager_load(:prerequisites, definition: [:phase, :categories])
    render json: V1::Workflow::ProcessProgressSerializer.new(processes)
  end

  def assigned_tasks
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    process_ids = Workflow::Instance::Process.where(workflow_id: workflow.id).pluck(:id)
    steps = Workflow::Instance::Step.where(process_id: process_ids).where.not(assignee_id: nil)

  end
end


