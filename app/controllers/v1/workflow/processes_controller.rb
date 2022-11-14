class V1::Workflow::ProcessesController < ApiController
  def show
    # TODO: identify current user, check if process id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:id])

    render json: V1::Workflow::ProcessSerializer.new(@process, include: ['workflow', 'steps', 'assignee'])
  end
end
