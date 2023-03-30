class V1::Workflow::ProcessesController < ApiController
  def index
    query = params[:workflow_id] ? { external_identifier: params[:workflow_id] } : { id: workflow_id }
    workflow = Workflow::Instance::Workflow.find_by!(query)

    processes = nil
    if params[:phase]
      if SSJ::Phase::PHASES.include?(params[:phase])
        # find definitions tagged with phase, then load those instances.
        phase_process_ids = workflow.definition.processes.tagged_with(params[:phase], on: :phase).pluck(:id)
        # then find the defintions with "start considering = true" from the next phase
        next_phase = SSJ::Phase.next(params[:phase])
        start_considering_process_ids = workflow.definition.processes.tagged_with(next_phase, on: :phase).where(start_considering: true).pluck(:id)

        process_ids = phase_process_ids + start_considering_process_ids
        processes = workflow.processes.where(definition_id: process_ids).eager_load(:categories, steps: [:definition, :documents], definition: [:categories, steps: [:documents]]).by_position
      else
        render :not_found
        return
      end
    else
      processes = workflow.processes.eager_load(:categories, steps: [:definition, :documents], definition: [:categories, steps: [:documents]]).by_position
    end

    options = {include: ['workflow', 'steps', 'steps.documents']}

    render json: V1::Workflow::ProcessSerializer.new(processes, options)
  end

  def show
    # TODO: identify current user, check if process id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:id])

    render json: V1::Workflow::ProcessSerializer.new(@process, params: { prerequisites: true }, include: ['workflow', 'steps', 'steps.documents', 'prerequisite_processes'])
  end

  private

  def process_options
    options = {}
    options[:include] = ['workflow', 'steps']
  end
end
