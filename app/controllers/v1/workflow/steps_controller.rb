class V1::Workflow::StepsController < ApiController
  def create
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    step_creator = Workflow::Instance::Process::AddManualStep.new(@process, step_params)
    @step = step_creator.run
    render json: V1::Workflow::StepSerializer.new(@step)
  end

  def show
    # TODO: identify current user, check if process/step id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    @step = @process.steps.find_by!(external_identifier: params[:id])
    render json: V1::Workflow::StepSerializer.new(@step)
  end

  def complete
    # TODO: identify current user, check if process/step id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    @step = @process.steps.find_by!(external_identifier: params[:id])

    completer = Workflow::Instance::Step::Complete.new(@step)
    completer.run

    render json: V1::Workflow::StepSerializer.new(@step)
  end

  def uncomplete
    # TODO: identify current user, check if process/step id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    @step = @process.steps.find_by!(external_identifier: params[:id])

    uncompleter = Workflow::Instance::Step::Uncomplete.new(@step)
    uncompleter.run

    render json: V1::Workflow::StepSerializer.new(@step)
  end

  private

  def step_params
    params.require(:step).permit(:title, :completed, :kind, :position, :resource_url, :resource_title)
  end
end
