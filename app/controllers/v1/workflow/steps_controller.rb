class V1::Workflow::StepsController < ApiController
  def show
    # TODO: identify current user, check if process/step id is accessible to user
    process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    step = process.steps.find_by!(external_identifier: params[:id])
    render json: V1::Workflow::StepSerializer.new(step)
  end

  def update
    process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    step = process.steps.find_by!(external_identifier: params[:id])
    step.update!(step_params)
    render json: V1::Workflow::StepSerializer.new(step)
  end

  private

  def step_params
    params.require(:step).permit(:title, :completed, :kind, :position, :resource_url, :resource_title)
  end
end
