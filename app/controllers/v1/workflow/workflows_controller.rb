class V1::Workflow::WorkflowsController < ApiController
  def show
    # TODO: identify current user, check if workflow id is accessible to user
    # figure out which workflows they have with that ID

    @workflow = Workflow::Instance::Workflow.find_by(external_identifier: params[:id])
    render json: V1::Workflow::WorkflowSerializer.new(@workflow, include: ['processes'])
  end
end
