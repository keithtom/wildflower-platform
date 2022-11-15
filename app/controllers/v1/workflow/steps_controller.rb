class V1::Workflow::StepsController < ApiController
  def show
    # TODO: identify current user, check if process/step id is accessible to user
    @process = Workflow::Instance::Process.find_by!(external_identifier: params[:process_id])
    @step = @process.steps.find_by!(external_identifier: params[:id])
    render json: V1::Workflow::StepSerializer.new(@step, step_options)
  end

  private

  def step_options
    options = {}
    options[:include] = ['process']
    return options
  end
end
