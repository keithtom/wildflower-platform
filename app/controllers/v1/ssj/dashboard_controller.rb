class V1::Ssj::DashboardController < ApiController
  def resources
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    process_ids = Workflow::Instance::Process.where(workflow_id: workflow.id).pluck(:id)
    steps = Workflow::Instance::Step.where(process_id: process_ids).includes(:documents, definition: [:documents, :process])
    documents = steps.map{|step| step.documents}.flatten
    render json: V1::Ssj::ResourcesByCategorySerializer.new(documents)
  end
end
