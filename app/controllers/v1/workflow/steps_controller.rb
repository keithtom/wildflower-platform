class V1::Workflow::StepsController < ApiController
  before_action :find_step, except: [:create]

  def create
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    @step = Workflow::Instance::Process::AddManualStep.run(@process, step_params)
    render json: V1::Workflow::StepSerializer.new(@step, step_options)
  end

  def show
    render json: V1::Workflow::StepSerializer.new(@step, step_options)
  end

  def complete
    @person = current_user.person
    Workflow::Instance::Step::Complete.run(@step, @person)

    render json: V1::Workflow::StepSerializer.new(@step, step_options)
  end

  def uncomplete
    @person = current_user.person
    Workflow::Instance::Step::Uncomplete.run(@step, @person)

    render json: V1::Workflow::StepSerializer.new(@step, step_options)
  end

  def reorder
    Workflow::Instance::Process::ReorderSteps.run(@step, step_params[:after_position])
    render json: V1::Workflow::StepSerializer.new(@step, step_options)

    rescue Workflow::Instance::Process::ReorderSteps::Error => e
      render json: {error: e.message}, status: :unprocessable_entity
  end

  def select_option
    @decision_option = Workflow::DecisionOption.find_by!(external_identifier: step_params[:selected_option_id])
    @person = current_user.person

    Workflow::Instance::Step::SelectDecisionOption.run(@step, @person, @decision_option)
    render json: V1::Workflow::StepSerializer.new(@step.reload, step_options)
  end

  def assign
    @person = current_user.person
    
    Workflow::Instance::Step::AssignPerson.run(@step, @person)

    render json: V1::Workflow::StepSerializer.new(@step.reload, step_options)
  end

  def unassign
    @person = current_user.person

    Workflow::Instance::Step::UnassignPerson.run(@step, @person)

    render json: V1::Workflow::StepSerializer.new(@step.reload, step_options)
  end

  private

  def step_options
    options = {}
    options[:include] = ['process', 'documents', 'assignments']
    return options
  end

  def find_step
    @step = find_team.workflow.steps.find_by!(external_identifier: params[:id])
  end

  # TODO: have a different set of params for a manual step
  def step_params
    # still would send this param? keep assignment of step the same interface.
    params.require(:step).permit(:title, :position, :document, :after_position, :selected_option_id)
  end
end
