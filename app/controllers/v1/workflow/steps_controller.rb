class V1::Workflow::StepsController < ApiController
  def create
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    @step = Workflow::Instance::Process::AddManualStep.run(@process, step_params)
    render json: V1::Workflow::StepSerializer.new(@step)
  end

  def show
    # TODO: identify current user, check if process/step id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    @step = @process.steps.find_by!(external_identifier: params[:id])
    render json: V1::Workflow::StepSerializer.new(@step, step_options)
  end

  def complete
    # TODO: identify current user, check if process/step id is accessible to user
    @step = Workflow::Instance::Step.find_by!(external_identifier: params[:id])

    Workflow::Instance::Step::Complete.run(@step)

    render json: V1::Workflow::StepSerializer.new(@step)
  end

  def uncomplete
    # TODO: identify current user, check if process/step id is accessible to user
    @step = Workflow::Instance::Step.find_by!(external_identifier: params[:id])

    Workflow::Instance::Step::Uncomplete.run(@step)

    render json: V1::Workflow::StepSerializer.new(@step)
  end

  def reorder
    @step = Workflow::Instance::Step.find_by!(external_identifier: params[:id])
    Workflow::Instance::Process::ReorderSteps.run(@step, step_params[:after_position])
    render json: V1::Workflow::StepSerializer.new(@step)

    rescue Workflow::Instance::Process::ReorderSteps::Error => e
      render json: {error: e.message}, status: :unprocessable_entity
  end

  def select_option
    @step = Workflow::Instance::Step.find_by!(external_identifier: params[:id])
    @decision_option = Workflow::DecisionOption.find_by!(external_identifier: step_params[:selected_option_id])

    Workflow::Instance::Step::SelectDecisionOption.run(@step, @decision_option)
    render json: V1::Workflow::StepSerializer.new(@step.reload)
  end

  private

  def step_options
    options = {}
    options[:include] = ['process', 'documents']
    return options
  end


  def step_params
    params.require(:step).permit(:title, :completed, :kind, :position, :document, :after_position, :selected_option_id)
  end
end
