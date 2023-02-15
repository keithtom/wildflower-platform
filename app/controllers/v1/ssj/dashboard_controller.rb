class V1::Ssj::DashboardController < ApiController

  def progress
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    processes = workflow.processes.eager_load(:prerequisites, :steps, :categories, definition: [:phase, :categories])
    render json: V1::Ssj::ProcessProgressSerializer.new(processes)
  end

  def resources
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    process_ids = Workflow::Instance::Process.where(workflow_id: workflow.id).pluck(:id)
    steps = Workflow::Instance::Step.where(process_id: process_ids).includes(:documents, definition: [:documents, :process])
    documents = steps.map{|step| step.documents}.flatten
    render json: V1::Ssj::ResourcesByCategorySerializer.new(documents)
  end

  def assigned_steps
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    process_ids = Workflow::Instance::Process.where(workflow_id: workflow.id).pluck(:id)
    steps = Workflow::Instance::Step.where(process_id: process_ids, completed: false).where.not(assignee_id: nil).
      includes(:process, :documents, :selected_option, :assignee, definition: [:documents]).
      group_by{|step| step.assignee.external_identifier }

    options = {}
    options[:include] = ['documents']
    render json: V1::Ssj::AssignedStepsSerializer.new(steps, options)
  end
end

