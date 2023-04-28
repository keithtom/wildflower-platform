class V1::Workflow::ProcessesController < ApiController
  def index
    query = params[:workflow_id] ? { external_identifier: params[:workflow_id] } : { id: workflow_id }
    workflow = Workflow::Instance::Workflow.find_by!(query)
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
      # instance should eager load prerequisites?  we shouldn't serialize these. unneded
      # eager load taggings from definition?
      # user: keithtom
      # GET /v1/workflow/workflows/c502-4f84/processes
      # USE eager loading detected
      #   Workflow::Instance::Process => [:prerequisites]
      #   Add to your query: .includes([:prerequisites])
      # Call stack
      #   /Users/keithtom/workspace/wildflower-platform/app/serializers/concerns/v1/statusable.rb:32:in `prerequisites_completed?'
      #   /Users/keithtom/workspace/wildflower-platform/app/serializers/concerns/v1/statusable.rb:16:in `process_status'
      #   /Users/keithtom/workspace/wildflower-platform/app/serializers/v1/workflow/process_serializer.rb:8:in `block in <class:ProcessSerializer>'
      #   /Users/keithtom/workspace/wildflower-platform/app/serializers/application_serializer.rb:10:in `to_json'
      #   /Users/keithtom/workspace/wildflower-platform/app/controllers/v1/workflow/processes_controller.rb:27:in `index'

      # user: keithtom
      # GET /v1/workflow/workflows/c502-4f84/processes
      # USE eager loading detected
      #   Workflow::Definition::Process => [:taggings]
      #   Add to your query: .includes([:taggings])
      # Call stack
      #   /Users/keithtom/workspace/wildflower-platform/app/serializers/v1/workflow/process_serializer.rb:16:in `block in <class:ProcessSerializer>'
      #   /Users/keithtom/workspace/wildflower-platform/app/serializers/application_serializer.rb:10:in `to_json'
      #   /Users/keithtom/workspace/wildflower-platform/app/controllers/v1/workflow/processes_controller.rb:27:in `index'

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
