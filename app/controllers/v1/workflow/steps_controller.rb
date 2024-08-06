class V1::Workflow::StepsController < ApiController
  before_action :assign_step, except: %i[create show unassign reorder]

  def create
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    @step = Workflow::Instance::Process::AddManualStep.run(@process, step_params)
    render_step
  end

  def show
    @step = Workflow::Instance::Step.includes(:process, :documents,
                                              assignments: [:assignee]).find_by!(external_identifier: params[:id])
    render_step
  end

  def complete
    @person = current_user.person
    Workflow::Instance::Step::Complete.run(@step, @person)

    render_step
  end

  def uncomplete
    @person = current_user.person
    Workflow::Instance::Step::Uncomplete.run(@step, @person)
    render_step
  end

  def reorder
    @step = find_step(nil)
    Workflow::Instance::Process::ReorderSteps.run(@step, step_params[:after_position])
    render_step
  rescue Workflow::Instance::Process::ReorderSteps::Error => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def select_option
    @decision_option = Workflow::DecisionOption.find_by!(external_identifier: step_params[:selected_option_id])
    @person = current_user.person

    Workflow::Instance::Step::SelectDecisionOption.run(@step, @person, @decision_option)
    render_step
  end

  def assign
    people = Person.includes(%i[schools ssj_team_member])
    @person = params[:person_id] ? people.find_by!(external_identifier: params[:person_id]) : people.find(current_user.person_id)
    Workflow::Instance::Step::AssignPerson.run(@step, @person)
    render_step
  end

  def unassign
    @step = find_step(:process, :documents, :assignments)
    @person = current_user.person
    assignee = Person.find_by!(external_identifier: params[:assignee_id])
    Workflow::Instance::Step::UnassignPerson.run(@step, assignee, @person)
    render_step
  rescue Workflow::Instance::Step::UnassignPersonError => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def render_step
    render json: V1::Workflow::StepSerializer.new(@step.reload, serialization_options)
  end

  def serialization_options
    options = {}
    options[:params] = { current_user: }
    options[:include] = ['process', 'documents', 'assignments', 'assignments.assignee']
    options
  end

  def assign_step
    @step = find_step(:process, :documents, assignments: [:assignee])
  end

  def find_step(*includes)
    Workflow::Instance::Step.includes(*includes).find_by!(external_identifier: params[:id])
  end

  # TODO: have a different set of params for a manual step
  def step_params
    # still would send this param? keep assignment of step the same interface.
    params.require(:step).permit(:title, :position, :document, :completion_type, :after_position, :selected_option_id)
  end
end
