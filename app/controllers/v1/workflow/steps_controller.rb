class V1::Workflow::StepsController < ApiController
  def show
    # TODO: identify current user, check if step id is accessible to user
    @step = Workflow::Instance::Step.find_by(external_identifier: params[:id])

    render json: V1::Workflow::StepSerializer.new(@step)
  end
end
