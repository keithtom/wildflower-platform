class V1::Workflow::ProcessesController < ApiController
  def show
    # TODO: identify current user, check if process id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:id])

    render json: V1::Workflow::ProcessSerializer.new(@process, include: ['workflow', 'steps', 'assignee'])
  end

  def assign
    # TODO: identify current user, check if process id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:id])
    @person = Person.find_by!(external_identifier: process_params[:assignee_id])

    assigner = Workflow::Instance::Process::AssignPerson.new(@process, @person)
    assigner.run

    render json: V1::Workflow::ProcessSerializer.new(@process, include: ['workflow', 'steps', 'assignee'])
  end

  private

  def process_params
    params.require(:process).permit(:assignee_id)
  end
end
