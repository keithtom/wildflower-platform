class V1::Workflow::StepsController < ApiController
  before_action :assign_step, except: [:create, :unassign, :reorder]

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
    @step = find_step(get_workflow, nil)
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
    @step = find_step(get_workflow, :process, :documents, :assignments)
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
    options[:params] = { current_user: current_user }
    options[:include] = ['process', 'documents', 'assignments', 'assignments.assignee']
    options
  end

  def assign_step
    @step = find_step(get_workflow, :process, :documents, assignments: [:assignee])
  end

  def get_workflow
    workflow_id = params[:workflow_id]
    workflow_id ? Workflow::Instance::Workflow.find_by!(external_identifier: workflow_id) : find_team.workflow
  end

  def find_step(workflow, *includes)
    workflow.steps.includes(*includes).find_by!(external_identifier: params[:id])
  end

  # TODO: have a different set of params for a manual step
  def step_params
    # still would send this param? keep assignment of step the same interface.
    params.require(:step).permit(:title, :position, :document, :completion_type, :after_position, :selected_option_id)
  end
end
