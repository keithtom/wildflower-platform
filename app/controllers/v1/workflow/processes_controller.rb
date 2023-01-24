class V1::Workflow::ProcessesController < ApiController
  def index
    # find the current_user's workflow, or load by :workflow_id
    puts "############### about to find workflow"
    puts "this is the workflow id"
    puts params[:workflow_id]
    workflow = Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id])
    puts "WORKFLOW WAS FOUND"

    processes = nil
    if params[:phase]
      if Workflow::Definition::Workflow::PHASES.include?(params[:phase])
        # find definitions tagged with phase, then load those instances.
        process_ids = workflow.definition.processes.tagged_with(params[:phase], on: :phase).pluck(:id)
        processes = workflow.processes.where(definition_id: process_ids).eager_load(:categories, steps: [:definition, :documents], definition: [:categories, steps: [:documents]]).by_position
      else
        puts "#############3 phase not included"
        render :not_found
        return
      end
    else
      processes = workflow.processes.eager_load(:categories, steps: [:definition, :documents], definition: [:categories, steps: [:documents]]).by_position
    end


    render json: V1::Workflow::ProcessSerializer.new(processes, include: ['workflow', 'steps'])
  end

  def show
    # TODO: identify current user, check if process id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:id])

    render json: V1::Workflow::ProcessSerializer.new(@process, include: ['workflow', 'steps'])
  end
end
