class V1::Workflow::SsjController < ApiController
  def dashboard
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    processes = workflow.processes.eager_load(:categories, steps: [:definition, :documents], definition: [:categories, steps: [:documents]])

    render json: V1::Workflow::ProcessByStatusSerializer.new(processes, {include: ['workflow', 'steps', 'steps.documents']})
  end
end


