class V1::Workflow::ProcessesController < ApiController
  def index
    serialization_options = {
      params: { current_user: current_user },
      include: ['workflow', 'steps', 'steps.documents', 'steps.assignments'],
      fields: { # whitelist what we think should go there and it should match what's eager loaded
        # process: [],
        # step: []
      }
    }
    eager_load_associations = [:categories, :prerequisites, steps: [:definition, :documents, :assignments], definition: [:taggings, :categories, steps: [:documents]]]

    if params[:omit_include]
      serialization_options.delete(:include)
      eager_load_associations = [:categories, :prerequisites, definition: [:taggings, :categories]]
    end

    processes = nil
    if params[:phase]
      if SSJ::Phase::PHASES.include?(params[:phase])
        # find definitions tagged with phase, then load those instances.
        process_ids = workflow.definition.processes.tagged_with(params[:phase], on: :phase).pluck(:id)
        
        # don't serialize prerequisites, not needed
        # https://github.com/jsonapi-serializer/jsonapi-serializer#conditional-relationships
        # https://github.com/jsonapi-serializer/jsonapi-serializer#sparse-fieldsets

        processes = workflow.processes.where(definition_id: process_ids).eager_load(*eager_load_associations).by_position
      else
        render :not_found
        return
      end
    else
      processes = workflow.processes.eager_load(*eager_load_associations).by_position
    end

    render json: V1::Workflow::ProcessSerializer.new(processes, serialization_options)
  end

  def show
    # TODO: identify current user, check if process id is accessible to user; use a find_process helper.
    eager_load_associations = { steps: [:documents, :assignments, definition: [:documents, :decision_options]] }
    
    # need to include decision options for step? seems like an attribute.
    serialization_options = {
      params: { prerequisites: true, current_user: current_user },
      fields: [], # use prerequisites here to turn it on or off.
      include: ['workflow', 'steps', 'steps.documents', 'steps.decision_options', 'steps.assignments', 'steps.assignments.assignee',
        'steps.assignments.selected_option',
        'prerequisite_processes']
    }

    @process = Workflow::Instance::Process.includes(eager_load_associations).find_by!(external_identifier: params[:id])
    render json: V1::Workflow::ProcessSerializer.new(@process, serialization_options)
  end
end
