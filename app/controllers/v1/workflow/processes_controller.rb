class V1::Workflow::ProcessesController < ApiController
  def index
    # find the current_user's workflow, or load by :workflow_id
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])

    processes = nil
    if params[:phase]
      if Workflow::Definition::Workflow::PHASES.include?(params[:phase])
        # find definitions tagged with phase, then load those instances.
        process_ids = workflow.definition.processes.tagged_with(params[:phase], on: :phase).pluck(:id)
        processes = workflow.processes.where(definition_id: process_ids).by_position
      else
        render :not_found
        return
      end
    else
      processes = workflow.processes.by_position
    end


    render json: V1::Workflow::ProcessSerializer.new(processes, include: ['workflow', 'steps', 'assignee'])
  end

  def show
    # TODO: identify current user, check if process id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:id])

    render json: V1::Workflow::ProcessSerializer.new(@process, include: ['workflow', 'steps', 'assignee'])
  end

  def assign
    # TODO: identify current user, check if process id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:id])
    @person = Person.find_by!(external_identifier: process_params[:assignee_id])

    Workflow::Instance::Process::AssignPerson.run(@process, @person)

    render json: V1::Workflow::ProcessSerializer.new(@process, include: ['workflow', 'steps', 'assignee'])
  end

  private

  def process_params
    params.require(:process).permit(:assignee_id)
  end
end
