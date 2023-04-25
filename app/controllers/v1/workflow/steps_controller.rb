class V1::Workflow::StepsController < ApiController
  before_action :find_step, except: [:create]

  def create
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    @step = Workflow::Instance::Process::AddManualStep.run(@process, step_params)
    render_step
  end

  def show
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
    Workflow::Instance::Process::ReorderSteps.run(@step, step_params[:after_position])
    render_step

    rescue Workflow::Instance::Process::ReorderSteps::Error => e
      render json: {error: e.message}, status: :unprocessable_entity
  end

  def select_option
    @decision_option = Workflow::DecisionOption.find_by!(external_identifier: step_params[:selected_option_id])
    @person = current_user.person

    Workflow::Instance::Step::SelectDecisionOption.run(@step, @person, @decision_option)
    render_step
  end

  def assign
    @person = current_user.person
    Workflow::Instance::Step::AssignPerson.run(@step, @person)
    render_step
  end

  def unassign
    @person = current_user.person
    Workflow::Instance::Step::UnassignPerson.run(@step, @person)
    render_step
  end

  private

  def render_step
    render json: V1::Workflow::StepSerializer.new(@step.reload, serialization_options)
  end

  def serialization_options
    options = {}
    options[:include] = ['process', 'documents', 'assignments', 'assignments.assignee']
    options[:params] = { current_user: current_user }
    options
  end

  def find_step
    @step = find_team.workflow.steps.includes(:process, :documents, assignments: [:assignee]).find_by!(external_identifier: params[:id])
  end

  # TODO: have a different set of params for a manual step
  def step_params
    # still would send this param? keep assignment of step the same interface.
    params.require(:step).permit(:title, :position, :document, :completion_type, :after_position, :selected_option_id)
  end
end
